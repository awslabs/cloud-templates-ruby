require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Chained filter documentation provider
            #
            # Goes over all elements in the chain composing a list of filters
            class Chain < Rdoc::Contextualized::Filter
              for_entity Templates::Utils::Contextualized::Filter::Chain

              def to_processed
                sub(text('a chain of the following filters:'), filters)
              end

              private

              def filters
                list do |l|
                  context.filters.each { |filter| l << processed_for(filter) }
                end
              end
            end
          end
        end
      end
    end
  end
end
