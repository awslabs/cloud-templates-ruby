require 'aws/templates/utils'

module UserDirectory
  module Rendering
    module Ldap
      ##
      # Basic render
      #
      # It just puts a link between children and type registrar
      class ArtifactView < Aws::Templates::Rendering::View
        register_in Ldap::Render
        artifact Aws::Templates::Artifact

        def prepare
          { dn: instance.dn, objectClass: object_class }
        end

        protected

        def object_class
          %w[top]
        end
      end
    end
  end
end
