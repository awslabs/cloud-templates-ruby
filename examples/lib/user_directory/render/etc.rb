require 'user_directory/render/etc/registry'

Dir.glob("#{File.dirname(__FILE__)}/etc/*.rb").each do |file|
  require file
end
