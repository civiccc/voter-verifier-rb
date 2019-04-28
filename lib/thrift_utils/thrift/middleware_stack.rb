module ThriftUtils
  module Thrift
    # An implementation of the middleware pattern (a la Rack) for RPC handling.
    # Extracts RPCs from a Thrift service and passes requests to a handler via
    # a middleware stack.
    class MiddlewareStack
      # @param thrift_service [Class] The Thrift service from which to extract RPCs
      # @param handlers [Array<Object>] An object or objects responding to each
      #   defined RPC; if multiple respond, the first will be used
      def initialize(thrift_service, handlers)
        @stack = []

        handlers = Array(handlers)
        @executor = ->(rpc) do
          handler = handlers.find { |h| h.respond_to?(rpc.name) }
          raise NoMethodError, "No handler found for rpc #{rpc.name}" unless handler
          handler.public_send(rpc.name, *rpc.args)
        end

        # define instance methods for each RPC, only on this instance
        Rpc.for_service(thrift_service).each do |rpc|
          define_singleton_method(rpc.name) do |*args, **opts|
            call(rpc.with_args(args, opts))
          end
        end
      end

      # A middleware is any class implementing #call and calling app.call in turn
      def use(klass, *args)
        @stack << [klass, args]
      end

      private

      # execute the middleware stack culminating in the RPC itself
      def call(rpc)
        compose.call(rpc)
      end

      # compose the stack functions: f(), g(), h() => f(g(h(rpc)))
      def compose
        @stack.reverse_each.reduce(@executor) do |app, (middleware, args)|
          middleware.new(app, *args)
        end
      end
    end
  end
end
