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
          Templates::Rendering::Utils::Stringify.process(self)
        end

        def inspect
          Templates::Rendering::Utils::Inspect.process(self)
        end
      end
    end
  end
end
