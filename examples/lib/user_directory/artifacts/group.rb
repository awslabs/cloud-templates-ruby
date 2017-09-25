require 'aws/templates/artifact'
require 'aws/templates/utils/parametrized/constraints'
require 'aws/templates/utils/parametrized/transformations'
require 'user_directory/artifacts/ided'
require 'user_directory/artifacts/catalogized'
require 'user_directory/artifacts/pathed'

module UserDirectory
  ##
  # POSIX Group
  class Group < Aws::Templates::Artifact
    include IDed
    include Catalogized

    default dn: proc { "cn=#{name},ou=System,#{organization.dn}" },
            cn: proc { name }

    parameter :cn, description: 'Group canonical name', constraint: not_nil
    parameter :name, description: 'Group name'
    parameter :organization,
              description: 'Organization object',
              constraint: not_nil,
              transform: as_object(Catalogized)
    parameter :members,
              description: 'Group members list',
              transform: as_list(
                name: :member,
                description: 'Member in the group',
                constraint: not_nil,
                transform: as_object do
                  parameter :login,
                            description: 'User login',
                            constraint: not_nil
                end
              )
  end
end
