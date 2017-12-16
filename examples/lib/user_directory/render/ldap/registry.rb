require 'aws/templates/utils'

module UserDirectory
  module Render
    ##
    # LDIF render
    #
    # Transforms formed catalog artifacts into LDIF definition.
    module Ldap
      extend Aws::Templates::Render::Utils::BaseTypeViews
      initialize_base_type_views
      register ::Pathname, Aws::Templates::Render::Utils::BaseTypeViews::ToString
    end
  end
end
