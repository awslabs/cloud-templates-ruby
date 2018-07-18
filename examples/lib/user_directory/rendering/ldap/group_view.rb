require 'aws/templates/utils'

module UserDirectory
  module Rendering
    module Ldap
      ##
      # POSIX group render
      #
      # Creates group LDIF entry.
      class GroupView < ArtifactView
        artifact UserDirectory::Artifacts::Group

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
