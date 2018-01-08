require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Add filter documentation provider
            class Add < RecursiveSchemaFilter
              for_entity Templates::Utils::Contextualized::Filter::Add

              blurb 'merge the following options from the parent context:'
            end
          end
        end
      end
    end
  end
end
