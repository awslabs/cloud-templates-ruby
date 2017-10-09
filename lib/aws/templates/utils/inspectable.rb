module Aws
  module Templates
    module Utils
      ##
      # Inspect mixin.
      #
      # Mixin provides means of composing inspect strings for objects through framework's rendering
      # mechanism.
      module Inspectable
        def to_s
          ::Kernel.require 'aws/templates/render/utils/stringify'
          ::Aws::Templates::Render::Utils::Stringify.view_for(self).to_rendered
        end

        def inspect
          ::Kernel.require 'aws/templates/render/utils/inspect'
          ::Aws::Templates::Render::Utils::Inspect.view_for(self).to_rendered
        end
      end
    end
  end
end
