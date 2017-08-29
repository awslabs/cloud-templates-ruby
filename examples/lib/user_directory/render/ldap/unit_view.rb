require 'user_directory/render/ldap/composite_view'
require 'user_directory/artifacts/unit'

module UserDirectory
  module Render
    module LDAP
      ##
      # Catalog's org unit render
      #
      # It renders into unit's LDIF entry with merged list of children.
      class UnitView < CompositeView
        artifact UserDirectory::Unit

        protected

        def entry
          super().merge(ou: instance.name)
        end

        def object_class
          super() << 'organizationalUnit'
        end
      end
    end
  end
end
