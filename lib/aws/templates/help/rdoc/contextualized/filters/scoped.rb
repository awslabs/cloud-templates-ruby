require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Scope filter documentation provider
            #
            # Outputs documentation for the nested filter and scope.
            class Scoped < Contextualized::Filter
              for_entity Templates::Utils::Contextualized::Filter::Scoped

              def to_processed
                sub(
                  text('scoped filter'),
                  processed_for(context.scoped_filter),
                  text("... to be executed in the scope #{context.scope}")
                )
              end
            end
          end
        end
      end
    end
  end
end
