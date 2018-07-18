require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Chained transformation documentation
            #
            # Generates documentation blocks for all transformation steps in the chain.
            class AsChain < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsChain

              def to_processed
                sub(text('as chain of transformations:'), transformations)
              end

              private

              def transformations
                context.components
                       .lazy
                       .map { |c| processed_for(c) }
                       .each_with_object(list) { |part, l| l << part }
              end
            end
          end
        end
      end
    end
  end
end
