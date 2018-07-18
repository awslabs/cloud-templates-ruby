require 'user_directory/rendering/ldap/render'

Dir.glob("#{File.dirname(__FILE__)}/ldap/*.rb").each do |file|
  require file
end
