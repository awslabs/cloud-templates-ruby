require 'aws/templates/utils'

module UserDirectory
  module Rendering
    module Etc
      ##
      # Basic render
      #
      # It just puts a link between children and type registrar
      class ArtifactView < Aws::Templates::Rendering::View
        register_in Etc::Render
      end
    end
  end
end
