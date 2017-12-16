require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # Team composite
    #
    # Each team has a POSIX group assigned to its members, a manager,
    # and subordinates. That's exactly what is represented here.
    class Team < Unit
      parameter :manager, description: 'Manager description hash', constraint: not_nil
      parameter :subordinates,
                description: 'List of subordinates\' descriptions',
                constraint: not_nil
      parameter :group_id, description: 'Team\'s group ID'

      components do
        group = artifact Artifacts::Group,
                         label: 'group',
                         name: name.downcase.tr(' ', '_'),
                         id: group_id

        contextualize(group: group) do
          manager_artifact = artifact Artifacts::Person, manager.merge(label: 'manager')

          # Circular dependency between group and its members
          subordinates_artifacts = contextualize(manager: manager_artifact) do
            subordinates.map { |subordinate| artifact Artifacts::Person, subordinate }
          end

          group.options[:members] = subordinates_artifacts << manager_artifact
        end
      end
    end
  end
end
