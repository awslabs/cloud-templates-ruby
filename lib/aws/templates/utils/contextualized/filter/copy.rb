require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Add all options into the context
          #
          # The filter performs deep copy of entire options hash with consecutive merge into the
          # resulting context
          #
          # === Example
          #
          #    class Piece
          #      contextualize filter(:copy)
          #    end
          #
          #    i = Piece.new()
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => { a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 } }
          class Copy < self
            using Contextualized::Refinements

            PRE_FILTER = %i[label root parent meta].freeze

            def filter(opts, memo, _)
              result = Utils.deep_dup(opts.to_hash)
              PRE_FILTER.each { |k| result.delete(k) }
              Utils.merge(memo, result)
            end
          end
        end
      end
    end
  end
end
