require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Proc proxy
          #
          # Just passes opts to the proc the filter was initialized with. It is used internaly.
          class Proxy < self
            using Contextualized::Refinements

            attr_reader :proc

            def initialize(prc, &blk)
              @proc = prc || blk
            end

            def filter(opts, memo, instance)
              instance.instance_exec(opts, memo, &proc)
            end
          end
        end
      end
    end
  end
end
