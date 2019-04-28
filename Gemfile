source 'https://rubygems.org'


gem 'activesupport', require: 'active_support/all'
gem 'activemodel'
gem 'anujdas-thrift-validator'
gem 'configatron'
gem 'connection_pool'
gem 'dogstatsd-ruby', '~> 4.0', require: 'datadog/statsd'
gem 'elasticsearch', '~> 1.1'
gem 'elasticsearch-dsl'
# 0.15 is currently incompatible (likely with `sentry-raven` 2.7.2)
gem 'faraday', '~> 0.9', '< 0.15'
gem 'faraday_middleware'
gem 'oj'
gem 'rake'
gem 'sentry-raven', require: false
gem 'thrift', '~> 0.9'

gem 'thrift_defs', path: 'thrift/ruby'



group :development, :test do
  gem 'dotenv' # in docker, config is injected
  gem 'overcommit', require: false
  gem 'pry-byebug'
  gem 'rubocop', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'elasticsearch-extensions' # provides the Test::Cluster
  gem 'factory_bot'
  gem 'faker'
  gem 'rspec'
  gem 'rspec-its'
  gem 'timecop'
  gem 'webmock'
  gem 'rack-test'
end
