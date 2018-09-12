require 'erb'
require 'yaml'

require_relative './logger'

db_config_path = File.expand_path('../database.yml', __dir__)
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read(db_config_path)).result)

ActiveRecord::Base.establish_connection(ENV['BRIGADE_ENV'].to_sym)
ActiveRecord::Base.logger = LOGGER unless ENV['BRIGADE_ENV'] == 'production'
ActiveRecord::Base.send(:include, ServiceUtilities::CoreExt::ActiveRecord)
