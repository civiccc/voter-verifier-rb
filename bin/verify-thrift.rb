#!/usr/bin/env ruby -W0

require 'bundler'
Bundler.require

TARGET_DIR = ARGV[0]

# Push all the generated files into Ruby's load path, so it can be `require`d
RB_BUILD_DIR = File.expand_path(File.join('..', TARGET_DIR, 'gen-rb'), File.dirname(__FILE__))
$:.push RB_BUILD_DIR

# Now check that each file is successfully `require`d
Dir[File.join(RB_BUILD_DIR, '**', '*.rb')].each do |file|
  print "Test loading file #{File.basename(file)}... "
  require file
  puts 'OK'
end

puts 'Success!'
