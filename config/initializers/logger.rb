configatron.logger.file.sync = (configatron.logger.sync == true)
LOGGER = ThriftServer::Logger.new(configatron.logger.file,
                                  json: configatron.logger.json.enabled == true,
                                  pretty_print: configatron.logger.json.pretty_print == true)
LOGGER.level = configatron.logger.level
