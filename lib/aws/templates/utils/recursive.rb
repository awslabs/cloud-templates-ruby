require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Recusrsive refinement
      #
      # The refinement adds to_recursive method to all standard classes which support recursive
      # concept.
      module Recursive
        ##
        # Hash implements resursive concept
        refine ::Hash do
          def to_recursive
            self
          end
        end
      end
    end
  end
end
