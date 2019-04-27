require_relative '../../app/verification_server'

namespace :thrift_server do
  EXIT_SIGNALS = %w[QUIT INT TERM].freeze # should SIGINT clean-kill?

  def run_gracefully(daemon)
    EXIT_SIGNALS.each { |signal| trap(signal) { daemon.stop! } }
    daemon.start!
  end

  desc 'Start the verification service in listening mode.'
  task run: :environment do
    run_gracefully VerificationServer.new
  end
end
