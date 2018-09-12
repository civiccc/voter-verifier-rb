RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.definition_file_paths << 'spec/support/factories'
    FactoryBot.find_definitions
    FactoryBot.allow_class_lookup = false
  end
end
