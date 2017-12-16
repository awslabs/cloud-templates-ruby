require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # Catalog's person
    #
    # Represents UNIX user who is a real person. Contains all related
    # attributes.
    class Person < User
      default cn: proc { "#{given_name} #{last_name} (#{login})" }

      parameter :given_name, description: 'Person\'s given name', constraint: not_nil
      parameter :middle_name, description: 'Person\'s middle name'
      parameter :last_name, description: 'Person\'s last name', constraint: not_nil
      parameter :patronimic, description: 'Person\'s patronimic'
      parameter :phone,
                description: 'Desk phone number',
                constraint: UserDirectory::Utils.phone_number
      parameter :manager,
                description: 'Person\'s manager',
                transform: as_object(Artifacts::Catalogized)
    end
  end
end
