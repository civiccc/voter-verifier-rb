require 'oj'

module ThriftServer
  # A Logger that can output JSON if prompted
  class Logger < ::Logger
    # Logstash consumes JSON by the line, so emit single-line JSON instead of plaintext
    class JsonLogFormatter < ::Logger::Formatter
      # @param pretty_print [Boolean?] When truthy, output will be human-readable
      #   JSON, NOT SUITABLE for logstash
      def initialize(pretty_print: false)
        @hostname = Socket.gethostname.force_encoding('UTF-8')
        @revision = ENV['GIT_REVISION']
        @opts = if pretty_print
                  {
                    array_nl: "\n",
                    indent: '  ',
                    object_nl: "\n",
                    space: ' ',
                    symbol_keys: false,
                    mode: :custom,
                  }
                else
                  { symbol_keys: false, mode: :custom }
                end
      end

      def call(severity, time, progname, msg)
        payload = msg.is_a?(Hash) ? msg : { msg: msg2str(msg) }

        Oj.dump({
          severity: severity,
          time: time.utc.iso8601(3),
          hostname: @hostname,
          name: progname,
          pid: $$,
          thread_id: Thread.current.object_id,
          git_revision: @revision,
        }.merge(payload), @opts) + "\n"
      end
    end

    # @param logdev [String, IO] The file or handle to which to output
    # @param json [Boolean?] Whether to output JSON rather than plaintext,
    #   default true
    # @param pretty_print [Boolean?] Whether to output multi-line JSON, default
    #   false. Has no affect unless json logging is enabled.
    def initialize(logdev, json: true, pretty_print: false)
      super(logdev)
      self.formatter = JsonLogFormatter.new(pretty_print: pretty_print) if json
    end
  end
end
