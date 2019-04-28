require_relative '../thrift/middleware_stack'
require_relative '../thrift/pub_sub'

module ThriftServer
  module Middleware
    # middleware wraparound for thrift Handler
    class InstrumentedStack < ThriftUtils::Thrift::MiddlewareStack
      attr_reader :pub_sub_hub

      # @param thrift_service [Class] The Thrift service from which to extract RPCs
      # @param handlers [Array<Object>] An object or objects responding to each
      #   defined RPC; if multiple respond, the first will be used
      def initialize(thrift_service, handlers)
        super
        @pub_sub_hub = ThriftUtils::Thrift::PubSub.new
      end
    end

    # RPC event stat publisher
    class InstrumentationHook
      def initialize(app, publisher)
        @app = app
        @publisher = publisher
      end

      def call(rpc)
        start_time = Time.now

        @publisher.publish :rpc_incoming, rpc

        @app.call(rpc).tap do |response|
          latency = (Time.now - start_time) * 1000
          @publisher.publish :rpc_ok, rpc, response, latency: latency
        end
      rescue => e
        latency = (Time.now - start_time) * 1000
        msg_key = rpc.protocol_exception?(e) ? :rpc_exception : :rpc_error
        @publisher.publish msg_key, rpc, e, latency: latency

        raise
      end
    end

    # Performs explicit rather than implicit AR connection management to ensure
    # we don't run out of SQL connections. Note that this approach is suboptimal
    # from a contention standpoint (better to check out once per thread), but
    # that sync time should be irrelevant if we size our pool correctly, which we
    # do. It is also suboptimal if we have any handler methods that do not hit
    # the database at all, but honestly, I doubt that will happen.
    #
    # For more details, check out (get it?):
    # https://bibwild.wordpress.com/2014/07/17/activerecord-concurrency-in-rails4-avoid-leaked-connections/
    class ActiveRecordPool
      def initialize(app)
        require 'active_record'
        @app = app
      end

      def call(rpc)
        ActiveRecord::Base.connection_pool.with_connection { @app.call(rpc) }
      end
    end

    # Instruments RPCs for Skylight
    class SkylightInstrumentation
      # Mixin to be included in handlers, which instruments all rpcs
      module Mixin
        def handle(rpc_name, &block)
          send(:include, Skylight::Helpers)
          super(rpc_name, &block).tap do
            send(:instrument_method, rpc_name.to_sym, title: 'Wrapped RPC')
            send(:instrument_method, "_#{rpc_name}".to_sym, title: 'Handler')
          end
        end
      end

      def initialize(app)
        require 'skylight'
        @app = app
      end

      def call(rpc)
        Skylight.trace(rpc.name.to_s, 'rpc') do
          @app.call(rpc)
        end
      end
    end
  end
end
