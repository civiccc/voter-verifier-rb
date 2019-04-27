source 'https://rubygems.org'

gem 'rake'

gem 'configatron'
gem 'dogstatsd-ruby', require: 'datadog/statsd'
gem 'sentry-raven', require: false

gem 'activesupport', require: 'active_support/all'
gem 'elasticsearch', '~> 1.1'
gem 'elasticsearch-dsl'

gem 'service_utilities', git: 'git@github.com:brigade/service-utilities.git'
gem 'thrift_shop', git: 'git@github.com:brigade/thrift-shop-generated-rb.git'
gem 'thrift'

group :development, :test do
  gem 'dotenv' # in docker, config is injected
  gem 'overcommit', require: false
  gem 'pry-byebug'
  gem 'rubocop', require: false
end

group :test do
  gem 'elasticsearch-extensions' # provides the Test::Cluster
  gem 'factory_bot'
  gem 'faker'
  gem 'rspec'
  gem 'timecop'
end
