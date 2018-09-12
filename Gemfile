***REMOVED***

gem 'rake'

gem 'configatron'
gem 'dogstatsd-ruby', require: 'datadog/statsd'
gem 'sentry-raven', require: false
gem 'skylight', '~> 1.4.4'

gem 'activemodel'
gem 'activerecord'
gem 'activesupport', require: 'active_support/all'
gem 'mysql2'
gem 'mysql_online_migrations'
gem 'paranoia'

***REMOVED***
gem 'thrift'
***REMOVED***

group :development, :test do
  gem 'dotenv' # in docker, config is injected
  gem 'overcommit', require: false
  gem 'pry-byebug'
  gem 'rubocop', require: false
end

group :test do
  gem 'factory_bot'
  gem 'rspec'
  gem 'shoulda-matchers',
      git: 'https://github.com/thoughtbot/shoulda-matchers.git'
  gem 'timecop'
end
