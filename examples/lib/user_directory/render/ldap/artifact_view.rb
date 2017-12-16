require 'aws/templates/utils'

module UserDirectory
  module Render
    module Ldap
      ##
      # Basic render
      #
      # It just puts a link between children and type registrar
      class ArtifactView < Aws::Templates::Render::View
        register_in Render::Ldap
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
