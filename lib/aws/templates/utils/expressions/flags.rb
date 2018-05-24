module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Flags namespace
        #
        # Flags are empty mixins which serve the purpose of marking classes so they pass
        # type checks. The method is similar to the approach in Java and differs from the one based
        # on mixing in a flag method into the target classes by that you don't need to patch the
        # entire object hoerarchy to make the flag method available.
        module Flags
        end
      end
    end
  end
end
