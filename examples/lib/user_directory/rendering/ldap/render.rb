require 'aws/templates/utils'

module UserDirectory
  module Rendering
    module Ldap
      ##
      # LDIF render
      #
      # Transforms formed catalog artifacts into LDIF definition.
      class Render < Aws::Templates::Rendering::Render
        extend Aws::Templates::Rendering::Utils::BaseTypeViews
        initialize_base_type_views
        register ::Pathname, Aws::Templates::Rendering::Utils::BaseTypeViews::ToString
      end
    end
  end
end
