configatron.server do |server|
  server.port = ENV['VOTER_VERIFIER_PORT']&.to_i || 9095
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
  es.timeout = ENV['VOTER_VERIFIER_ES_TIMEOUT'] || 15
  es.retries = ENV['VOTER_VERIFIER_ES_RETRIES'] || 1
  es.hosts = (ENV['VOTER_VERIFIER_ES_HOSTS'] || 'localhost:9200').split(',')
  es.voter_record_index = ENV['VOTER_VERIFIER_ES_INDEX'] || 'voter_verifier'
  es.voter_record_doc_type = ENV['VOTER_VERIFIER_ES_DOC_TYPE'] || 'voter_record'
end

configatron.search do |s|
  s.contact do |cs|
    cs.default_max_results = 100
  end

  s.default_max_results = 3
end
