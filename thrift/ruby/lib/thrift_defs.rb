# require all thrift-generated ruby files in all subdirectories
Dir[File.expand_path('*/**/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
