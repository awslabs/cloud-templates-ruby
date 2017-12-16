require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Add specified keys into the hash
          #
          # Selective version of Copy filter. It adds key-value pairs or whole subtrees from
          # options into the memo hash. It does this according to specified schema represented
          # by combination of nested hashes and arrays. User can specify addition of values
          # at arbitrary depth in options hash hierarchy with arbitrar granularity.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:add, :a, :b, c: [:d])
          #    end
          #
          #    i = Piece.new()
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => { a: { q: 1 }, b: 2, c: { d: { r: 5 } } }
          class Add < RecursiveSchemaFilter
            using Contextualized::Refinements

            def filter(options, memo, _)
              _recurse_add(options, memo, scheme)
            end

            private

            def _recurse_add(opts, memo, schm)
              return unless Utils.recursive?(opts)

              if Utils.hashable?(schm)
                _scheme_add(opts, memo, schm.to_hash)
              elsif Utils.list?(schm)
                _list_add(opts, memo, schm.to_ary)
              end

              memo
            end

            def _list_add(opts, memo, list)
              list.each { |field| memo[field] = Utils.merge(memo[field], opts[field]) }
            end

            def _scheme_add(opts, memo, schm)
              schm.each_pair do |field, sub_scheme|
                next unless opts.include?(field)
                memo[field] = if sub_scheme.nil?
                  Utils.merge(memo[field], opts[field])
                else
                  _recurse_add(opts[field], memo[field] || {}, sub_scheme)
                end
              end
            end
          end
        end
      end
    end
  end
end
