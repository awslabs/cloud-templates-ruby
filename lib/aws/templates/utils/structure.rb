require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Shorthand for all the artifacts that specify both defaults and parameters
      module Structure
        include Templates::Utils::Default
        include Templates::Utils::Parametrized
      end
    end
  end
end
