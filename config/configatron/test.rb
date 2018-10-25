configatron.logger do |logger|
  logger.file = File.open('log/test.log', File::WRONLY | File::CREAT | File::APPEND)
  logger.sync = false
end

configatron.elasticsearch do |es|
  es.hosts = 'localhost:9250'
end
