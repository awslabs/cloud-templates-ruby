require 'user_directory/render/etc/registry'

module UserDirectory
  module Render
    module Etc
      ##
      # Basic render
      #
      # It just puts a link between children and type registrar
      class ArtifactView < Aws::Templates::Render::View
        register_in Render::Etc
      end
    end
  end
end
