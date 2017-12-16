require 'aws/templates/utils'

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
          Render::Utils::Stringify.view_for(self).to_rendered
        end

        def inspect
          Render::Utils::Inspect.view_for(self).to_rendered
        end
      end
    end
  end
end
