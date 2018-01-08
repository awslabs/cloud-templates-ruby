require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Remove filter documentation provider
            class Remove < RecursiveSchemaFilter
              for_entity Templates::Utils::Contextualized::Filter::Remove

              blurb 'remove the following parameters from the target context:'
            end
          end
        end
      end
    end
  end
end
