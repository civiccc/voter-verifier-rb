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
      ThriftDefs::VoterVerifier::Service,
      HANDLERS,
      port: configatron.server.port,
    )

    @server.subscribe ThriftServer::Instrumentation::Logging.new(logger: LOGGER)
  end

  def start!
    @server.start
  end

  def stop!
    Thread.new { @server.shutdown }
  end
end
