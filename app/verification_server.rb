require_relative '../config/init'

# VerificationServer initializes and starts an instance of ThriftServer
class VerificationServer
  HANDLERS = [
    RandomAddressHandler,
    VoterRecordSearchHandler,
    VoterRecordHandler,
  ].freeze

  def initialize
    @server = ThriftServer.threaded(
      ThriftShop::Verification::VerificationService,
      HANDLERS,
      port: configatron.server.port,
    )

    @server.use ThriftServer::Middleware::SkylightInstrumentation
    @server.subscribe ThriftServer::Instrumentation::Logging.
      new(logger: LOGGER, error_handler: Raven.method(:capture_exception))
    @server.subscribe ThriftServer::Instrumentation::Metrics.new(statsd: STATSD)
  end

  def start!
    @server.start
  end

  def stop!
    Thread.new { @server.shutdown }
  end
end
