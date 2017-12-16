require 'user_directory/render/ldap/registry'

Dir.glob("#{File.dirname(__FILE__)}/ldap/*.rb").each do |file|
  require file
end
