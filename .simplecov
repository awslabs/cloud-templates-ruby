SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.start do
  add_filter '/spec'
  add_group 'Lib', 'lib'
end
