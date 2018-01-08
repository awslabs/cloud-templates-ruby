require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # No-op filter documenation provider
            class Identity < Rdoc::Contextualized::Filter
              for_entity Templates::Utils::Contextualized::Filter::Identity

              def provide
                sub(text('don not change the context'))
              end
            end
          end
        end
      end
    end
  end
end
