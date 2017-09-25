require 'aws/templates/artifact'
require 'user_directory/render/ldap/registry'

module UserDirectory
  module Render
    module LDAP
      ##
      # Basic render
      #
      # It just puts a link between children and type registrar
      class ArtifactView < Aws::Templates::Render::View
        register_in Render::LDAP
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
