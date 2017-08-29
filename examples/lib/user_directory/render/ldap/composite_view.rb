require 'aws/templates/composite'
require 'user_directory/render/ldap/registry'

module UserDirectory
  module Render
    module LDAP
      ##
      # Composite render
      #
      # It aggregates LDIF entries from the children into a single list
      # putting composite's own LDIF entry into the list head.
      class CompositeView < Aws::Templates::Render::View
        register_in Render::LDAP
        artifact Aws::Templates::Composite

        def prepare
          rendered_for(instance.artifacts.values).flatten.unshift(entry)
        end

        protected

        def entry
          { dn: instance.dn, objectClass: object_class }
        end

        def object_class
          %w(top)
        end
      end
    end
  end
end
