require 'aws/templates/utils'

module UserDirectory
  module Rendering
    module Ldap
      ##
      # Composite render
      #
      # It aggregates LDIF entries from the children into a single list
      # putting composite's own LDIF entry into the list head.
      class CompositeView < Aws::Templates::Rendering::View
        register_in Ldap::Render
        artifact Aws::Templates::Composite

        def prepare
          rendered_for(instance.artifacts.values).flatten.unshift(entry)
        end

        protected

        def entry
          { dn: instance.dn, objectClass: object_class }
        end

        def object_class
          %w[top]
        end
      end
    end
  end
end
