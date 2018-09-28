require 'rubygems'
require 'bundler/setup'

def require_dir(path_from_root)
  Dir[File.expand_path("../../#{path_from_root}/**/*.rb", __FILE__)].
    sort.each { |f| require f }
end

# Determine the code environment
ENV['BRIGADE_ENV'] ||=
  ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'

# Load up gems automatically
Bundler.require(:default, ENV['BRIGADE_ENV'].to_sym)

# Load all files in order
require_dir 'lib'.freeze
require_dir 'app/lib'.freeze
require_dir 'app/models/concerns'.freeze
require_dir 'app/models'.freeze
require_dir 'app/handlers/helpers'.freeze
require_dir 'app/handlers'.freeze
require_dir 'app/queries'.freeze

# Initialize; we're ready to go
require_dir 'config/initializers'.freeze
