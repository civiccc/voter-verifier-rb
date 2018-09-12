require 'configatron'

RSpec.configure do |config|
  # make all configatron modifications example-local, allowing us to
  # change configatron in specs without breaking other specs as a result
  config.around(:each) do |example|
    configatron.temp { example.run }
  end
end
