require 'user_directory/render/etc/artifact_view'

module UserDirectory
  module Render
    module Etc
      ##
      # POSIX group render
      #
      # Creates group file entry.
      class GroupView < ArtifactView
        artifact UserDirectory::Group

        def prepare
          Diff.new [], [group_record.join(':')]
        end

        def group_record
          in_instance { [name, 'x', id, members.map(&:login).join(',')] }
        end
      end
    end
  end
end
