require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        ##
        # Filter functor class
        #
        # A filter is a Proc accepting input hash and providing output
        # hash which is expected to be a permutation of the input.
        # The proc is executed in instance context so instance methods can
        # be used for calculation.
        #
        # The class implements functor pattern through to_proc method and
        # closure. Essentially, all filters can be used everywhere where
        # a block is expected.
        #
        # It provides protected method filter which should be overriden in
        # all concrete filter classes.
        class Filter
          include Utils::Functor

          using Contextualized::Refinements

          ##
          # Chain filters
          def &(other)
            fltr = other.to_filter
            return self if fltr.is_a?(Identity)
            Chain.new(self, fltr)
          end

          def invoke(scope, opts, memo = {})
            filter(opts, memo, scope)
          end

          ##
          # Filter method
          #
          # * +opts+ - input hash to be filtered
          # * +instance+ - the instance filter is executed in
          def filter(opts, memo, instance); end

          def to_filter
            self
          end
        end
      end
    end
  end
end
