require 'aws/templates/utils'

module UserDirectory
  module Rendering
    module Ldap
      ##
      # Catalog's org unit render
      #
      # It renders into unit's LDIF entry with merged list of children.
      class UnitView < CompositeView
        artifact UserDirectory::Artifacts::Unit

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
