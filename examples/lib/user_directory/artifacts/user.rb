require 'aws/templates/artifact'
require 'aws/templates/utils/parametrized/constraints'
require 'aws/templates/utils/parametrized/transformations'
require 'user_directory/artifacts/ided'
require 'user_directory/artifacts/pathed'
require 'user_directory/artifacts/catalogized'

module UserDirectory
  ##
  # POSIX user
  class User < Aws::Templates::Artifact
    include IDed
    include Catalogized

    default dn: proc { "cn=#{cn},#{unit.dn}" },
            home_directory: proc { { path: "/home/#{login}" } },
            shell: { path: '/bin/sh' }

    parameter :cn, description: 'Object canonical name', constraint: not_nil
    parameter :login, description: 'User login', constraint: not_nil
    parameter :group,
              description: 'User main group',
              constraint: not_nil,
              transform: as_object(IDed)
    parameter :home_directory, description: 'Home directory', transform: as_object(Pathed)
    parameter :shell, description: 'Shell path', transform: as_object(Pathed)
    parameter :unit, description: 'User\'s organizational unit', transform: as_object(Catalogized)
  end
end
