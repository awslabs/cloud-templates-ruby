require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Abstract transformation provider
          class Transformation < Rdoc::Provider
            for_entity Templates::Utils::Parametrized::Transformation
          end
        end
      end
    end
  end
end
