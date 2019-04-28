module ThriftUtils
  module Thrift
    # a truly trivial pub/sub implementation for server events
    class PubSub
      def initialize
        @listeners = []
      end

      def subscribe(listener)
        @listeners << listener
      end

      # If a listener raises an exception, any future ones won't run: this is
      # not considered a bug. Don't raise.
      def publish(event, *args)
        @listeners.each { |l| l.send(event, *args) if l.respond_to?(event) }
      end
    end
  end
end
