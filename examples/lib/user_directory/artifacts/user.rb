require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # POSIX user
    class User < Aws::Templates::Artifact
      include Artifacts::Ided
      include Artifacts::Catalogized

      default dn: proc { "cn=#{cn},#{unit.dn}" },
              home_directory: proc { { path: "/home/#{login}" } },
              shell: { path: '/bin/sh' }

      parameter :cn, description: 'Object canonical name', constraint: not_nil
      parameter :login, description: 'User login', constraint: not_nil
      parameter :group,
                description: 'User main group',
                constraint: not_nil,
                transform: as_object(Artifacts::Ided)
      parameter :home_directory,
                description: 'Home directory',
                transform: as_object(Artifacts::Pathed)
      parameter :shell,
                description: 'Shell path',
                transform: as_object(Artifacts::Pathed)
      parameter :unit,
                description: 'User\'s organizational unit',
                transform: as_object(Artifacts::Catalogized)
    end
  end
end
