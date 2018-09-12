require 'shoulda-matchers'

RSpec.configure do |config|
  # rspec-rails would do this for us, but we don't have it
  config.define_derived_metadata(file_path: Regexp.new('/spec/models/')) do |metadata|
    metadata[:type] = :model
  end

  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model
end
