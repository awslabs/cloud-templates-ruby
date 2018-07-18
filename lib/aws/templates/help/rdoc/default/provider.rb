require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Default
          ##
          # Defaults documentation provider
          #
          # Describes defaults attached to the object. Generates a text block with header and
          # definition's description.
          class Provider < Rdoc::Provider
            for_entity Templates::Utils::Default

            def to_processed
              definition = processed_for(context.defaults_definition)
              definition && sub(text('_Defaults_'), definition)
            end
          end
        end
      end
    end
  end
end
