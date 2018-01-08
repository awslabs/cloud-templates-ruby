require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          ##
          # Context filter documentation provider
          #
          # Abstract filter documentation provider
          class Filter < Rdoc::Provider
            for_entity Templates::Utils::Contextualized::Filter
          end
        end
      end
    end
  end
end
