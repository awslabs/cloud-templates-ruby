require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Proxy filter documentation provider
            #
            # Prints documenation for the nested filter/proc.
            class Proxy < Rdoc::Contextualized::Filter
              for_entity Templates::Utils::Contextualized::Filter::Proxy

              def provide
                sub(
                  text('delegates to the following entity:'),
                  processed_for(context.proc)
                )
              end
            end
          end
        end
      end
    end
  end
end
