require 'forwardable'
require 'thrift'

module ThriftServer
  # A nonblocking thread-pooled Thrift server with some instrumentation hooks added.
  # mostly copied from
  # https://github.com/apache/thrift/blob/e8fbd8c3d559a26242e3fece09dda82551cd1a28/lib/rb/lib/thrift/server/non_blocking_server.rb
  class NonblockingServer < ::Thrift::NonblockingServer
    extend Forwardable

    def_delegators :@processor, :use, :publish, :subscribe

    def start(dry_run: false)
      publish :server_start, self
      serve unless dry_run
    end

    def serve
      @server_transport.listen
      @io_manager = start_io_manager

      begin
        loop do
          break if @server_transport.closed?
          begin
            rd, * = select([@server_transport], nil, nil, 0.1)
          rescue Errno::EBADF
            # closing the socket in shutdown paths causes select() to raise Errno::EBADF
            break
          end
          next if rd.nil?
          socket = @server_transport.accept
          publish :server_connection_opened, socket.handle.remote_address
          @io_manager.add_connection socket
        end
      rescue IOError # rubocop:disable Lint/HandleExceptions
      end
    ensure
      @transport_semaphore.synchronize do
        @server_transport.close
      end
      @io_manager&.ensure_closed
    end

    private

    def start_io_manager
      IOManager.
        new(@processor,
            @server_transport,
            @transport_factory,
            @protocol_factory,
            @num_threads,
            @logger).
        tap(&:spawn)
    end

    # Thread manager and work delegator
    class IOManager < ::Thrift::NonblockingServer::IOManager
      def spin_thread
        Worker.
          new(@processor,
              @transport_factory,
              @protocol_factory,
              @logger,
              @worker_queue).
          spawn
      end

      # Handler executor fed via pipes from network sockets
      class Worker < ::Thrift::NonblockingServer::IOManager::Worker
        def spawn
          Thread.new do
            @processor.publish :thread_pool_server_pool_change, delta: 1
            run
          end
        end

        private

        def run
          loop do
            cmd, *args = @queue.pop
            case cmd
            when :shutdown
              @processor.publish :thread_pool_server_pool_change, delta: -1
              break
            when :frame
              fd, frame = args
              begin
                otrans = @transport_factory.get_transport(fd)
                oprot = @protocol_factory.get_protocol(otrans)
                membuf = ::Thrift::MemoryBufferTransport.new(frame)
                itrans = @transport_factory.get_transport(membuf)
                iprot = @protocol_factory.get_protocol(itrans)
                @processor.process(iprot, oprot)
              rescue => e
                @processor.publish :server_internal_error, fd.handle.remote_address, e
              end
            end
          end
        end
      end
    end
  end
end
