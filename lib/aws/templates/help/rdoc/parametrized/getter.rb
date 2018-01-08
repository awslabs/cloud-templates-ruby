require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Abstract getter documentation provider
          class Getter < Rdoc::Provider
            for_entity Templates::Utils::Parametrized::Getter
          end
        end
      end
    end
  end
end
