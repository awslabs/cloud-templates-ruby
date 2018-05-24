module Aws
  module Templates
    module Utils
      ##
      # Something which can be compared for equality
      #
      # The auxiliary mixin adds necessary methods fir checking equality of two objects.
      module Equalizable
        def !=(other)
          !eql?(other)
        end

        def ==(other)
          eql?(other)
        end

        def eql?(other)
          (self.class == other.class) && equal_to?(other)
        end

        def equal_to?(_other)
          raise 'Should be overriden'
        end
      end
    end
  end
end
