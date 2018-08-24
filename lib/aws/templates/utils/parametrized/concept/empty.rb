require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Concept
          ##
          # Identity concept
          #
          # Empty concept.
          class Empty < self
            extend Utils::Singleton
          end
        end
      end
    end
  end
end
