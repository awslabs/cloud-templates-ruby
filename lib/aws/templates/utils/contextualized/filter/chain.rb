require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Chain filters
          #
          # The filter chains all passed filters to have chained
          # filter semantics.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:copy) & filter(:remove, :c) & filter(:override, a: 12, b: 15)
          #    end
          #
          #    i = Piece.new
          #    opts = Options.new(c: { e: 1 })
          #    opts.filter(i.filter) # => { a: 12, b: 15 }
          class Chain < self
            using Contextualized::Refinements

            attr_reader :filters

            def initialize(*flts)
              wrong_objects = flts.reject { |f| f.respond_to?(:to_proc) }
              unless wrong_objects.empty?
                raise(
                  "The following objects are not filters: #{wrong_objects.inspect}"
                )
              end

              @filters = flts.flat_map { |f| _as_flattened_filters(f) }
            end

            def filter(options, memo, instance)
              filters.inject(memo) { |acc, elem| instance.instance_exec(options, acc, &elem) }
            end

            private

            def _as_flattened_filters(flt)
              return flt unless flt.is_a?(self.class)
              flt.filters.flat_map { |obj| _as_flattened_filters(obj) }
            end
          end
        end
      end
    end
  end
end
