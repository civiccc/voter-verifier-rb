ENV['SKYLIGHT_ENV'] ||= ENV['BRIGADE_ENV']
Skylight.start!(probes: %w[faraday])
at_exit { Skylight.stop! }
