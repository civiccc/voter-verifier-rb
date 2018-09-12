ENV['SKYLIGHT_ENV'] ||= ENV['BRIGADE_ENV']
Skylight.start!(probes: %w[faraday redis])
at_exit { Skylight.stop! }
