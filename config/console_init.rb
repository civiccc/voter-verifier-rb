require File.expand_path('init', __dir__)
require 'factory_bot'

include FactoryBot::Syntax::Methods # rubocop:disable Style/MixinUsage

FactoryBot.definition_file_paths << 'spec/support/factories'
FactoryBot.find_definitions
