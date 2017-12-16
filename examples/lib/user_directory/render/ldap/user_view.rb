require 'aws/templates/utils'

module UserDirectory
  module Render
    module Ldap
      ##
      # POSIX user render
      #
      # It creates POSIX user LDIF entry
      class UserView < ArtifactView
        artifact UserDirectory::Artifacts::User

        def prepare
          super().merge(cn: instance.cn).merge(passwd_block)
        end

        def object_class
          super() << 'posixAccount'
        end

        def passwd_block
          {
            uid: instance.login,
            uidNumber: instance.id,
            gidNumber: instance.group.id,
            homeDirectory: path_for(instance.home_directory),
            loginShell: path_for(instance.shell),
            gecos: instance.login
          }
        end

        def path_for(obj)
          obj && obj.path.to_s
        end
      end
    end
  end
end
