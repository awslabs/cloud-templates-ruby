require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Simple memoization facility
      module Memoized
        # Cancel all memoizations
        def dirty!
          @memoized = nil
          self
        end

        ##
        # Memoize block result
        #
        # Return memoized value with the ID. If slot is empty - call the block
        def memoize(id)
          memoized[id] ||= yield
        end

        def memoized
          @memoized ||= {}
        end
      end
    end
  end
end
