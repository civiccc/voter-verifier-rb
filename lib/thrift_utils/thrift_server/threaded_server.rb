require 'forwardable'
require 'thrift'

module ThriftServer
  # A thread-per-connection Thrift server with some instrumentation hooks added.
  # mostly copied from
  # https://github.com/apache/thrift/blob/e8fbd8c3d559a26242e3fece09dda82551cd1a28/lib/rb/lib/thrift/server/threaded_server.rb
  class ThreadedServer < Thrift::ThreadedServer
    extend Forwardable

    def_delegators :@processor, :use, :publish, :subscribe

    def start(dry_run: false)
      @shutdown = false
      publish :server_start, self
      serve unless dry_run
    end

    def serve
      @server_transport.listen
      loop do
        Thread.new(@server_transport.accept) do |client|
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
      end
    rescue Errno::EBADF, IOError => _e
      # when the transport is closed during shutdown, EBADF will be raised by accept(),
      # or IOError if it's already closed while accept() is trying to read from it
      raise unless @shutdown
    ensure
      @server_transport.close
    end

    def shutdown(*)
      @shutdown = true
      @server_transport.close
    end
  end
end
