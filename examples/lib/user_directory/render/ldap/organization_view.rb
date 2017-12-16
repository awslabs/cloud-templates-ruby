require 'aws/templates/utils'

module UserDirectory
  module Render
    module Ldap
      ##
      # Catalog's organization render
      #
      # It renders into organization's LDIF entry with merged list of children.
      class OrganizationView < CompositeView
        artifact UserDirectory::Artifacts::Organization

        protected

        def entry
          super().merge(o: instance.name)
        end

        def object_class
          super() << 'organization'
        end
      end
    end
  end
end
