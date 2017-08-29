require 'user_directory/artifacts/user'
require 'user_directory/artifacts/person'
require 'user_directory/artifacts/group'
require 'user_directory/artifacts/unit'
require 'user_directory/artifacts/team'
require 'user_directory/artifacts/organization'

require 'user_directory/render/etc'
require 'user_directory/render/ldap'

##
# Example implementation of catalog
#
# This is a demonstration of how one could use the framework.
# In this example, we can render set of users and groups embedded
# into org structure into two principally different representations:
# * UNIX passwd/group files
# * LDIF definition
# It is important to emphasize that representations are rendered from
# the same logical source. It is an example of loosened MVC pattern
# used in the framework.
module UserDirectory
end
