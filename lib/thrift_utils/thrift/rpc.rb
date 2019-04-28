require 'thrift'

module ThriftUtils
  module Thrift
    # container for extracted info about an RPC
    class Rpc
      # extract array<Rpc> for a given thrift Service using a ton of reflection
      def self.for_service(thrift_service)
        # get all candidate classes that may contribute RPCs to this service
        root = thrift_service < ::Thrift::Processor ? thrift_service : thrift_service::Processor
        processors = root.ancestors.select { |klass| klass < ::Thrift::Processor }

        # { service_class[Class] => array<rpc_name[String]> }
        service_rpcs = processors.each_with_object({}) do |processor_class, hash|
          service_class = Object.const_get(processor_class.name.sub(/::Processor$/, ''))
          hash[service_class] = processor_class.
            instance_methods(false).
            select { |method_name| method_name =~ /^process_/ }.
            map { |method_name| method_name.to_s.sub(/^process_/, '') }
        end

        # array<Rpc(name[Symbol], exception[Set<Exception>])>
        service_rpcs.flat_map do |service_class, rpc_names|
          rpc_names.map do |rpc_name|
            result_class_name = "#{rpc_name.capitalize}_result"
            fields = service_class.const_get(result_class_name)::FIELDS.values
            exceptions = fields.map { |f| f[:class] }.select { |c| c&.< ::Thrift::Exception }

            new(name: rpc_name, exceptions: exceptions) # package it up
          end
        end
      end

      ###

      attr_reader :name, :exceptions

      def initialize(name:, exceptions:)
        @name = name.to_sym
        @exceptions = exceptions.to_set
      end

      # @param exception [Exception]
      # @return [Boolean] whether the exception is part of the RPC spec
      def protocol_exception?(exception)
        exceptions.include?(exception.class)
      end

      # @param args [Array<Object>] arguments passed to the RPC
      # @param opts [Hash<Symbol => Object>?] additional options for RPC preprocessing
      # @return [CalledRpc] an RPC representation additionally containing
      #   calling params and options
      def with_args(args, opts = {})
        CalledRpc.new(name: name, args: args, options: opts, exceptions: exceptions)
      end

      ###

      # container for an RPC including its call parameters (args)
      class CalledRpc < self
        attr_reader :args, :options

        def initialize(name:, args:, options:, exceptions:)
          super(name: name, exceptions: exceptions)
          @args = args
          @options = options
        end
      end
    end
  end
end
