require 'user_directory/render/ldap/composite_view'
require 'user_directory/artifacts/organization'

module UserDirectory
  module Render
    module LDAP
      ##
      # Catalog's organization render
      #
      # It renders into organization's LDIF entry with merged list of children.
      class OrganizationView < CompositeView
        artifact UserDirectory::Organization

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
