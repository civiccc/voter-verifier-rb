require_relative '../../app/example_server'

namespace :example_service do
  EXIT_SIGNALS = %w[QUIT INT TERM].freeze # should SIGINT clean-kill?

  def run_gracefully(daemon)
    EXIT_SIGNALS.each { |signal| trap(signal) { daemon.stop! } }
    daemon.start!
  end

  desc 'Start the example service in listening mode.'
  task run: :environment do
    run_gracefully ExampleServer.new
  end
end
