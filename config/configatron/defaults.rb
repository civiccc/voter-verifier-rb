configatron.server do |server|
  server.port = ENV['PORT']&.to_i || 9095
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

configatron.elasticsearch do |es|
  es.timeout = ENV['ELASTICSEARCH_TIMEOUT'] || 15
  es.retries = ENV['ELASTICSEARCH_RETRIES'] || 1
  es.hosts = (ENV['ELASTICSEARCH_HOSTS'] || 'localhost:9200').split(',')
  es.voter_record_index = ENV['ELASTICSEARCH_INDEX'] || 'voter_verifier'
  es.voter_record_doc_type = ENV['ELASTICSEARCH_DOC_TYPE'] || 'voters'
end

configatron.search do |s|
  s.contact do |cs|
    cs.default_max_results = 100
  end

  s.default_max_results = 3
end
