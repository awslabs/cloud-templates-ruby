require 'simplecov'
require 'simplecov-brazil'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::BrazilFormatter
]

SimpleCov.start do
  coverage_dir 'build/brazil-documentation/coverage'
  add_filter '/spec'
  add_group 'Lib', 'lib'
  add_group 'Templates', 'octane-workflow-templates'
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
