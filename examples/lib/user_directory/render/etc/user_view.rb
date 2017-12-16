require 'aws/templates/utils'

module UserDirectory
  module Render
    module Etc
      ##
      # POSIX user render
      #
      # It creates passwd file entry
      class UserView < ArtifactView
        artifact UserDirectory::Artifacts::User

        def prepare
          Diff.new [user_record.join(':')], []
        end

        def user_record
          [
            instance.login, 'x', instance.id, instance.group.id,
            user_info, path_for(instance.home_directory), path_for(instance.shell)
          ]
        end

        def user_info
          instance.login
        end

        def path_for(obj)
          obj && obj.path
        end
      end
    end
  end
end
