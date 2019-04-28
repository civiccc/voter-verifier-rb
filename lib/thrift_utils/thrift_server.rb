require 'forwardable'
require 'thrift'

require_relative './thrift_server/threaded_server'
require_relative './thrift_server/thread_pool_server'
require_relative './thrift_server/nonblocking_server'
require_relative './thrift_server/thrift_handler'

require_relative './thrift_server/instrumentation'
require_relative './thrift_server/middleware'
require_relative './thrift_server/logger'

# An extensible, instrumented builder pattern for Thrift-RPC servers
module ThriftServer
  class << self
    def threaded(processor, handler,
                 port: 9090,
                 transport_factory: Thrift::FramedTransportFactory.new,
                 protocol_factory: Thrift::BinaryProtocolFactory.new)
      processor = processor::Processor unless processor < ::Thrift::Processor
      stack = wrap(processor).new(handler)
      transport = Thrift::ServerSocket.new(port)

      ThreadedServer.new(stack, transport, transport_factory, protocol_factory)
    end

    def thread_pool(processor, handler,
                    port: 9090,
                    threads: 25,
                    transport_factory: Thrift::FramedTransportFactory.new,
                    protocol_factory: Thrift::BinaryProtocolFactory.new)
      processor = processor::Processor unless processor < ::Thrift::Processor
      stack = wrap(processor).new(handler)
      transport = Thrift::ServerSocket.new(port)

      ThreadPoolServer.new(stack, transport, transport_factory, protocol_factory, threads)
    end

    def non_blocking(processor, handler,
                     port: 9090,
                     threads: 25,
                     transport_factory: Thrift::FramedTransportFactory.new,
                     protocol_factory: Thrift::BinaryProtocolFactory.new,
                     logger: nil)
      processor = processor::Processor unless processor < ::Thrift::Processor
      stack = wrap(processor).new(handler)
      transport = Thrift::ServerSocket.new(port)

      NonblockingServer.new(stack, transport, transport_factory, protocol_factory, threads, logger)
    end

    private

    def wrap(processor)
      Class.new processor do
        extend Forwardable

        def_delegators :@handler, :use, :pub_sub_hub
        def_delegators :pub_sub_hub, :publish, :subscribe

        define_method :initialize do |handler|
          super Middleware::InstrumentedStack.new(processor, handler)
          use Middleware::InstrumentationHook, pub_sub_hub # default middleware
        end
      end
    end
  end
end
