require 'datadog/statsd'

module ThriftServer
  module Instrumentation
    # A ThriftServer subscriber for RPC metrics reporting
    class Metrics
      def initialize(statsd:)
        raise ArgumentError, 'Only dogstatsd is supported' unless statsd.is_a?(Datadog::Statsd)
        ***REMOVED***
        @statsd = statsd
      end

      def server_connection_opened(_remote_address)
        increment :'server.connection.active'
        gauge :'server.threads', Thread.list.length
      end

      # An unknown error occurred in internal Thrift logic (transport/protocol)
      # @param remote_address [IPAddr] the other end of the connection
      # @param exception [Thrift::Exception] The to-be-serialized exception
      def server_internal_error(_remote_address, _exception)
        increment :'server.internal_error'
      end

      def server_connection_closed(_remote_address)
        decrement :'server.connection.active'
        gauge :'server.threads', Thread.list.length
      end

      def rpc_incoming(rpc)
        increment :'rpc.incoming', tags: ["rpc:#{rpc.name}"]
      end

      # Everything went according to plan
      # @param rpc [ThriftUtils::Thrift::Rpc] A wrapper struct around an RPC request
      # @param response [Thrift::Struct] The to-be-serialized thrift response object
      # @param meta [Hash] Details about the RPC call, specifically :latency
      def rpc_ok(rpc, _response, meta)
        tags = ["rpc:#{rpc.name}", 'rpc.status:success']
        increment :'rpc.incoming.success', tags: ["rpc:#{rpc.name}"]
        timing :'rpc.incoming.latency', meta[:latency], tags: tags
      end

      # Handler raised an exception defined in the protocol
      # @param rpc [ThriftUtils::Thrift::Rpc] A wrapper struct around an RPC request
      # @param exception [Thrift::Exception] The to-be-serialized thrift exception
      # @param meta [Hash] Details about the RPC call, specifically :latency
      def rpc_exception(rpc, exception, meta)
        tags = ["rpc:#{rpc.name}", 'rpc.status:exception', "rpc.exception:#{exception.class.name}"]
        if exception.respond_to?(:exception_class)
          e_class = exception.exception_class
          e_class = ThriftDefs::ExceptionTypes::ExceptionClass::VALUE_MAP[e_class] if e_class.is_a?(Integer)
          tags << "rpc.exception_class:#{e_class}"
        end
        increment :'rpc.incoming.exception', tags: tags
        timing :'rpc.incoming.latency', meta[:latency], tags: tags
      end

      # Handler raised an unexpected error
      # @param rpc [ThriftUtils::Thrift::Rpc] A wrapper struct around an RPC request
      # @param exception [StandardError] The to-be-serialized thrift exception
      # @param meta [Hash] Details about the RPC call, specifically :latency
      def rpc_error(rpc, exception, meta)
        tags = ["rpc:#{rpc.name}", 'rpc.status:error', "rpc.error:#{exception.class.name}"]
        increment :'rpc.incoming.error', tags: tags
        timing :'rpc.incoming.latency', meta[:latency], tags: tags
      end

      private

      def increment(stat, by: 1, tags: [])
        @statsd.increment stat, by: by, tags: tags + @global_tags
      end

      def decrement(stat, by: 1, tags: [])
        @statsd.decrement stat, by: by, tags: tags + @global_tags
      end

      def timing(stat, ms, tags: [])
        @statsd.timing stat, ms, tags: tags + @global_tags
      end

      def gauge(stat, value, tags: [])
        @statsd.gauge stat, value, tags: tags + @global_tags
      end
    end

    # A ThriftServer subscriber for RPC logging and exception recording
    class Logging
      BACKTRACE_LINES = 5 # lines to include in logs -- full stacktrace goes to error_handler

      def initialize(logger:, error_handler: nil)
        @logger = logger
        @error_proc = error_handler || ->(e, **_) {}
      end

      def thread_pool_server_pool_change(meta)
        @logger.debug :server do
          'Thread pool change: %+d' % [meta.fetch(:delta)]
        end
      end

      def server_connection_opened(remote_address)
        @logger.debug :server do
          "#{remote_address.ip_address}:#{remote_address.ip_port} connected"
        end
      end

      # An unknown error occurred in internal Thrift logic (transport/protocol)
      # @param remote_address [IPAddr] the other end of the connection
      # @param exception [Thrift::Exception] The to-be-serialized exception
      def server_internal_error(remote_address, exception)
        @logger.error :server do
          {
            remote_address: "#{remote_address.ip_address}:#{remote_address.ip_port}",
            exception: exception_to_hash(exception),
          }
        end
        @error_proc.call(exception)
      end

      def server_connection_closed(remote_address)
        @logger.debug :server do
          "#{remote_address.ip_address}:#{remote_address.ip_port} disconnected"
        end
      end

      # Everything went according to plan
      # @param rpc [ThriftUtils::Thrift::Rpc] A wrapper struct around an RPC request
      # @param response [Thrift::Struct] The to-be-serialized thrift response object
      # @param meta [Hash] Details about the RPC call, specifically :latency
      def rpc_ok(rpc, response, meta)
        @logger.info :rpc do
          {
            req: rpc_to_hash(rpc),
            res: response_to_hash(response),
            meta: meta,
          }
        end
      end

      # Handler raised an exception defined in the protocol
      # @param rpc [ThriftUtils::Thrift::Rpc] A wrapper struct around an RPC request
      # @param exception [Thrift::Exception] The to-be-serialized thrift exception
      # @param meta [Hash] Details about the RPC call, specifically :latency
      def rpc_exception(rpc, exception, meta)
        @logger.info :rpc do
          {
            req: rpc_to_hash(rpc),
            res: { exception: exception_to_hash(exception) },
            meta: meta,
          }
        end
      end

      # Handler raised an unexpected error
      # @param rpc [ThriftUtils::Thrift::Rpc] A wrapper struct around an RPC request
      # @param exception [Thrift::Exception] The to-be-serialized thrift exception
      # @param meta [Hash] Details about the RPC call, specifically :latency
      def rpc_error(rpc, exception, meta)
        rpc_hash = rpc_to_hash(rpc)

        @logger.error :rpc do
          {
            req: rpc_hash,
            res: { error: exception_to_hash(exception, backtrace: true) },
            meta: meta,
          }
        end

        user_context = rpc_hash.dig(:headers, :auth)
        request_context = { request_id: rpc_hash.dig(:headers, :req_id) }
        @error_proc.call(exception, user: user_context, extra: request_context)
      end

      private

      def rpc_to_hash(rpc)
        headers, *args = rpc.args
        entity = headers.entity

        {
          method: rpc.name,
          headers: {
            req_id: headers.request_id,
            auth: {
              id: entity&.uuid,
              uuid: entity&.uuid,
              role: entity&.role,
              role_str: ThriftDefs::AuthTypes::EntityRole::VALUE_MAP[entity&.role]&.downcase,
            },
            context: headers.context.as_json,
          },
          args: args.as_json,
        }
      end

      def response_to_hash(response)
        if response.is_a?(Thrift::Struct) || response.is_a?(Thrift::Union)
          response.as_json
        elsif response.is_a?(Enumerable)
          { enumerable: { type: response.first.class.name, values: response.as_json } }
        else
          { primitive: { response.class.name => response } }
        end
      end

      def exception_to_hash(exception, backtrace: false)
        hash = { type: exception.class.name, message: exception.message }
        hash[:backtrace] = exception.backtrace.first(BACKTRACE_LINES) if backtrace

        hash[exception.class.name.downcase.gsub('::', '_')] =
          exception.instance_variables.each_with_object({}) do |var, h|
            h[var.to_s.sub('@', '')] = exception.instance_variable_get(var)
          end

        hash
      end
    end
  end
end
