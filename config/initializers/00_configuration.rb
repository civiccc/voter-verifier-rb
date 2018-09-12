begin
  require 'dotenv'

  # Load settings from .env
  env_files = [
    '.env.local',
    ".env.#{ENV['BRIGADE_ENV']}",
    '.env',
  ]

  Dotenv.load(*env_files)
rescue LoadError # rubocop:disable Lint/HandleExceptions
  # Dotenv not used in prod
end

# Load settings from configatron
require 'configatron'

config_files = [
  'configatron/defaults',
  "configatron/#{ENV['BRIGADE_ENV']}",
  'configatron/local',
]

config_files.each do |f|
  filename = File.expand_path("../../#{f}.rb", __FILE__)
  require filename if File.exist?(filename)
end
