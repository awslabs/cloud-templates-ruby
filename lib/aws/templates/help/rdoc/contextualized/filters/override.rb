require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Override filter documentation provider
            #
            # Generates blurb and documentation for override object whatever the object is.
            # The object provider is taken from standard documenation provider
            class Override < Rdoc::Contextualized::Filter
              for_entity Templates::Utils::Contextualized::Filter::Override

              def to_processed
                sub(
                  text('merge the context with the following override:'),
                  processed_for(context.override)
                )
              end
            end
          end
        end
      end
    end
  end
end
