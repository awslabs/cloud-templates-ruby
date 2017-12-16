require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Remove specified keys from hash
          #
          # The filter performs removal of values from options hash
          # according to specified schema represented by combination of
          # nested hashes and arrays. User can specify removal of values
          # at arbitrary depth in options hash hierarchy with arbitrary
          # granularity.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:copy) & filter(:remove, :a, :b, c: [:d])
          #    end
          #
          #    i = Piece.new()
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => { c: { e: 1 } }
          class Remove < RecursiveSchemaFilter
            using Contextualized::Refinements

            def filter(_, memo, _)
              _recurse_remove(memo, scheme)
              memo
            end

            private

            def _recurse_remove(opts, schm)
              return unless Utils.recursive?(opts)

              if Utils.hashable?(schm)
                _scheme_remove(opts, schm.to_hash)
              elsif Utils.list?(schm)
                _list_remove(opts, schm.to_ary)
              end
            end

            def _list_remove(opts, list)
              list.each { |field| opts.delete(field) }
            end

            def _scheme_remove(opts, schm)
              schm.each_pair do |field, sub_scheme|
                if sub_scheme.nil?
                  opts.delete(field)
                elsif opts.include?(field)
                  _recurse_remove(opts[field], sub_scheme)
                end
              end
            end
          end
        end
      end
    end
  end
end
