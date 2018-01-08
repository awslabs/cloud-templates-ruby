require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Copy filter documentation provider
            class Copy < Rdoc::Contextualized::Filter
              for_entity Templates::Utils::Contextualized::Filter::Copy

              def provide
                sub(text('copy the entire context'))
              end
            end
          end
        end
      end
    end
  end
end
