require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Nested object definition documentation provider
          #
          # Very similar to Artifact provider except it doesn't have a few aspects.
          class Nested < Help::Aggregate
            include Rdoc::Texting

            register_in Rdoc::Processor
            for_entity Templates::Utils::Parametrized::Nested

            after Templates::Utils::Parametrized, Templates::Utils::Default

            protected

            def fragment; end

            def compose(fragments)
              list(:BULLET, *fragments)
            end
          end
        end
      end
    end
  end
end
