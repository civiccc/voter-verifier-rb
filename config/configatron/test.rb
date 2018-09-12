configatron.logger do |logger|
  logger.file = File.open('log/test.log', File::WRONLY | File::CREAT | File::APPEND)
  logger.sync = false
end
