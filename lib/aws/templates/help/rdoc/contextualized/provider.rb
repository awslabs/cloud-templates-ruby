require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          ##
          # Context filtering documentation aspect provider
          #
          # Describes context filtering in a separate text block.
          class Provider < Rdoc::Inheritable
            for_entity Templates::Utils::Contextualized

            header 'Components scope filters'

            protected

            def description_for(mod)
              return if mod.module_context.is_a?(Templates::Utils::Contextualized::Filter::Identity)
              processed_for(mod.module_context)
            end
          end
        end
      end
    end
  end
end
