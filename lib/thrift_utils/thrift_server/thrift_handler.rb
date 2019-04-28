require 'active_model/callbacks'
require 'thrift'

require_relative '../thrift/rpc'

module ThriftServer
  # Processes remote procedure calls from Thrift, optionally invoking hooks
  # before or after the business logic is executed.
  class ThriftHandler
    class << self
      private

      # @param processor [Thrift::Processor] The processor class to implement
      # @param only [Array<Symbol>?] The rpc names to implement; must be a subset of processor's
      def process(processor, only: nil)
        extend ActiveModel::Callbacks
        # reflect a bit to get all declared thrift-rpc endpoints
        @rpc_names = ThriftUtils::Thrift::Rpc.for_service(processor).map(&:name)
        @rpc_names &= only if only
        # generate some entry points for before/around/after filters
        define_model_callbacks :handle
        @rpc_names.each { |rpc_name| define_model_callbacks rpc_name }
      end

      # define .handle, used to create thrift-rpc endpoint handlers
      def handle(rpc_name, &block)
        raise '.process must be called before RPCs can be defined' unless @rpc_names

        unless @rpc_names.include?(rpc_name)
          raise "#{rpc_name} is not a method: try #{@rpc_names}."
        end

        # define an instance method matching the thrift endpoint, without callbacks
        private define_method("_#{rpc_name}".to_sym, &block)

        # define an instance method matching the thrift endpoint, with callbacks
        define_method(rpc_name) { run_with_hooks(rpc_name) }

        # define a class method matching the thrift endpoint which instantiates
        # the handler, enabling threadsafe usage of instance variables.
        define_singleton_method(rpc_name) do |*args|
          new(*args).public_send(rpc_name)
        end
      end
    end

    attr_reader :headers, :request, :params

    def initialize(*args)
      # @request should be an instance variable, but some things rely on it being
      # the first element in @params. Ideally, this should be:
      #   @headers, @request, *@params = *args
      @headers, *@params = *args
      @request = @params.first
    end

    private

    def run_with_hooks(rpc_name)
      run_callbacks :handle do
        run_callbacks rpc_name do
          # See the comment in initialize for more context.
          # Eventually, @params will not include the request, but some code
          # assumes that it's in @params. Avoid it being duplicated by passing
          # params without its first element.
          send "_#{rpc_name}".to_sym, headers, request, *params[1..-1]
        end
      end
    end
  end
end
