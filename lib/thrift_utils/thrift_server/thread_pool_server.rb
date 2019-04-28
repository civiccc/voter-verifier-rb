require 'forwardable'
require 'thrift'

module ThriftServer
  # A fixed-size thread-pooled Thrift server with some instrumentation hooks added.
  # mostly copied from
  # https://github.com/apache/thrift/blob/e8fbd8c3d559a26242e3fece09dda82551cd1a28/lib/rb/lib/thrift/server/thread_pool_server.rb
  class ThreadPoolServer < Thrift::ThreadPoolServer
    extend Forwardable

    def_delegators :@processor, :use, :publish, :subscribe

    def start(dry_run: false)
      publish :server_start, self
      serve unless dry_run
    end

    def serve # rubocop:disable Metrics/MethodLength
      @server_transport.listen

      begin
        loop do # rubocop:disable Metrics/BlockLength
          @thread_q.push(:token)

          Thread.new do # rubocop:disable Metrics/BlockLength
            begin
              publish :thread_pool_server_pool_change, delta: 1

              loop do
                client = @server_transport.accept
                remote_address = client.handle.remote_address
                transport = @transport_factory.get_transport(client)
                protocol = @protocol_factory.get_protocol(transport)

                begin
                  publish :server_connection_opened, remote_address
                  loop do
                    @processor.process(protocol, protocol)
                  end
                rescue Thrift::ProtocolException => e
                  publish :server_internal_error, remote_address, e
                rescue Thrift::TransportException # rubocop:disable Lint/HandleExceptions
                  # this is normal when a client disconnects
                ensure
                  publish :server_connection_closed, remote_address
                  transport.close
                end
              end
            rescue => e
              @exception_q.push(e)
            ensure
              publish :thread_pool_server_pool_change, delta: -1
              @thread_q.pop # thread died!
            end
          end
        end
      ensure
        @server_transport.close
      end
    end

    def shutdown(*)
      @server_transport.close
    end
  end
end
