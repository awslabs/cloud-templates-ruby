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
          using Contextualized::Refinements
          ##
          # Chain filters
          def &(other)
            fltr = other.to_filter
            return self if fltr.is_a?(Identity)
            Chain.new(self, fltr)
          end

          ##
          # Creates closure with filter invocation
          #
          # It's an interface method required for Filter to expose
          # functor properties. It encloses invocation of Filter
          # filter method into a closure. The closure itself is
          # executed in the context of Filtered instance which provides
          # proper set "self" variable.
          #
          # The closure itself accepts just one parameter:
          # * +opts+ - input hash to be filtered
          # ...where instance is assumed from self
          def to_proc
            fltr = self
            ->(opts, memo = {}) { fltr.filter(opts, memo, self) }
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
