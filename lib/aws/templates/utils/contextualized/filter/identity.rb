require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # No-op filter
          #
          # No-op filter or identity filter doesn't perform any operations on passed options. The
          # role of this filter is to play the role of identity function in par with lambda
          # calculus.
          #
          # === Examples
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:identity)
          #    end
          #
          #    i = Piece.new
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => {}
          class Identity < self
            using Contextualized::Refinements

            def self.new
              @new ||= super()
            end

            def filter(_, memo, _)
              memo
            end

            def &(other)
              other.to_filter
            end
          end
        end
      end
    end
  end
end
