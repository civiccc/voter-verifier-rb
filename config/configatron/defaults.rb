configatron.service do |service|
  service.name = 'verification_service'.freeze
  service.host = ENV['SERVICE_HOST'].presence.freeze
end

configatron.server do |server|
  server.port = ENV['PORT']&.to_i || ***REMOVED***
end

configatron.statsd do |statsd|
  statsd.host = 'localhost'
  statsd.port = 18125
  statsd.namespace = configatron.service.name
end

configatron.logger do |logger|
  logger.file = STDOUT
  logger.sync = true # flush output after every line
  logger.level = Logger::DEBUG
  logger.json do |json|
    json.enabled = true
    json.pretty_print = true
  end
end

configatron.sentry.dsn = ENV['SENTRY_DSN'].freeze

configatron.field_encryption do |e|
  # `#keys` is reserved in configatron
  e.fe_keys = { 'AES|1' => Base64.decode64(ENV['FIELD_ENCRYPTION_KEY']) }
  e.current_scheme = e.fe_keys.keys.last
end

configatron.elasticsearch do |es|
  es.timeout = ENV['ELASTICSEARCH_TIMEOUT'] || 15
  es.retries = ENV['ELASTICSEARCH_RETRIES'] || 1
  es.hosts = (ENV['ELASTICSEARCH_HOSTS'] || 'localhost:9200').split(',')
  es.voter_record_index = ENV['ELASTICSEARCH_INDEX'] || 'votizen_verifier'
  es.voter_record_doc_type = ENV['ELASTICSEARCH_DOC_TYPE'] || 'voters'
end
