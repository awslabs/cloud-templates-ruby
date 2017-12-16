require 'aws/templates/utils'

module UserDirectory
  module Render
    module Ldap
      ##
      # Person render
      #
      # It merges POSIX user entry with additional fields and object
      # types valid for a real person.
      class PersonView < UserView
        artifact UserDirectory::Artifacts::Person

        def prepare
          hsh = in_instance do
            hsh = {
              gecos: "#{cn},,#{phone}",
              givenName: given_name,
              sn: last_name
            }

            hsh[:manager] = manager.dn if manager

            hsh
          end

          super().merge(hsh)
        end

        protected

        def object_class
          super().concat(%w[inetOrgPerson person])
        end
      end
    end
  end
end
