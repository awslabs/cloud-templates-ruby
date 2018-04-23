require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Parameter documentation provider
          #
          # Combines parameter description and documentation blocks for constraint, getter and
          # transformation if they are assigned to the parameter.
          class Parameter < Rdoc::Provider
            for_entity Templates::Utils::Parametrized::Parameter

            def provide
              item = sub(description)

              unless context.concept.nil? || context.concept.empty?
                item << processed_for(context.concept)
              end

              item
            end

            private

            def description
              desc = "_#{context.name}_ "
              desc.concat(context.description) if context.description
              text(desc)
            end
          end
        end
      end
    end
  end
end
