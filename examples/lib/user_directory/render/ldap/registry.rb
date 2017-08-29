require 'aws/templates/render/utils/base_type_views'
require 'pathname'

module UserDirectory
  module Render
    ##
    # LDIF render
    #
    # Transforms formed catalog artifacts into LDIF definition.
    module LDAP
      extend Aws::Templates::Render::Utils::BaseTypeViews
      initialize_base_type_views
      register Pathname, Aws::Templates::Render::Utils::BaseTypeViews::ToString
    end
  end
end
