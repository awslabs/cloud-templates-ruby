require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Override specified keys in options hash
          #
          # The filter performs merge the hash passed at initialization with
          # options hash. Either hash itself or block returning a hash
          # can be specified. The block will be evaluated in instance context
          # so all instance methods are accessible.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:copy) & filter(:override, a: 12, b: 15, c: { d: 30 })
          #    end
          #
          #    i = Piece.new
          #    opts = Options.new(c: { e: 1 })
          #    opts.filter(i.filter) # => { a: 12, b: 15, c: { d: 30, e: 1 } }
          class Override < self
            using Contextualized::Refinements

            attr_reader :override

            def initialize(override = nil, &override_block)
              @override = _check_override_type(override || override_block)
            end

            def filter(_, memo, instance)
              Utils.merge(
                memo,
                if override.respond_to?(:to_hash)
                  override
                elsif override.respond_to?(:to_proc)
                  instance.instance_eval(&override)
                end
              )
            end

            private

            def _check_override_type(ovrr)
              raise "Wrong override value: #{ovrr.inspect}" unless _proper_override_type?(ovrr)
              ovrr
            end

            def _proper_override_type?(ovrr)
              ovrr.respond_to?(:to_hash) || ovrr.respond_to?(:to_proc)
            end
          end
        end
      end
    end
  end
end
