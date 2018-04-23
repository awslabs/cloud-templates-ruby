module Aws
  module Templates
    module Utils
      ##
      # Simple singleton implementation
      #
      # Overrides new method to provide memoized instance.
      module Singleton
        def new
          @new ||= super
        end
      end
    end
  end
end
