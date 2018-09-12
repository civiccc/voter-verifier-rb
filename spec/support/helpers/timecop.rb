require 'timecop'

RSpec.configure do |config|
  config.around(:each) do |example|
    Timecop.freeze(Time.now.beginning_of_day) { example.run }
  end
end
