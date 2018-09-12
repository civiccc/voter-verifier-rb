ENV['BRIGADE_ENV'] ||= 'test' # in case we didn't set it explicitly

# initialise all code
require File.expand_path('../config/init', __dir__)

# require all spec helpers
Dir[File.expand_path('support/helpers/*', __dir__)].each do |f|
  require f
end

# require all shared_contexts
Dir[File.expand_path('support/shared_contexts/*', __dir__)].each do |f|
  require f
end

# require all shared_examples
Dir[File.expand_path('support/shared_examples/*', __dir__)].each do |f|
  require f
end

# Checks for pending migrations before tests are run
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_tests = true

  config.disable_monkey_patching!

  config.order = :random
  Kernel.srand config.seed # set manually w/ --seed 1234

  config.profile_examples = 10

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  # This can be used by accessing `fixture_path` in specs.
  # eg File.read(File.join(fixture_path, 'my_file.csv'))
  config.fixture_path = File.expand_path('support/file_fixtures', __dir__)

  # Extremely noisy on thrift code; enable at your own risk
  # config.warnings = true

  ###
  # RSpec 4 comatibility stuff
  ###

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
