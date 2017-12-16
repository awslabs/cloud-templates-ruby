require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # POSIX Group
    class Group < Aws::Templates::Artifact
      include Artifacts::Ided
      include Artifacts::Catalogized

      default dn: proc { "cn=#{name},ou=System,#{organization.dn}" },
              cn: proc { name }

      parameter :cn, description: 'Group canonical name', constraint: not_nil
      parameter :name, description: 'Group name'
      parameter :organization,
                description: 'Organization object',
                constraint: not_nil,
                transform: as_object(Artifacts::Catalogized)
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
end
