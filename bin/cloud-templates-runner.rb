#!/usr/bin/env ruby

require 'aws/templates/runner'

begin
  puts Aws::Templates::Runner.with(ARGV, STDIN).run!
rescue Aws::Templates::Runner::HelpException => e
  puts e.message
  exit
rescue Aws::Templates::Runner::ParameterException => e
  puts 'Invalid or missing parameter'
  puts e.message
  exit 1
rescue OptionParser::MissingArgument => e
  puts e.message
  exit 2
end
