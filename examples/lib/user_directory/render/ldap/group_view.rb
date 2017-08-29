require 'user_directory/render/ldap/artifact_view'
require 'user_directory/artifacts/group'

module UserDirectory
  module Render
    module LDAP
      ##
      # POSIX group render
      #
      # Creates group LDIF entry.
      class GroupView < ArtifactView
        artifact UserDirectory::Group

        def prepare
          super().merge(
            in_instance { { cn: cn, gidNumber: id, memberUid: members.map(&:login) } }
          )
        end

        protected

        def object_class
          super() << 'posixGroup'
        end
      end
    end
  end
end
