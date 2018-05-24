require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Universal proxy class
      #
      # Proxies every not defined method call to the target
      class Proxy < BasicObject
        attr_reader :delegate

        def self.inherited(klass)
          super
          klass.send(:define_method, :class) { klass }
        end

        ##
        # Equality
        #
        # Two proxy objects are equal if it's the same object or if they are pointing to the
        # same target.
        def eql?(other)
          equal?(other) ||
            ((self.class == other.class) && delegate.eql?(other.delegate)) ||
            delegate.eql?(other)
        end

        ##
        # == operator
        #
        # The idea is the same as for eql? However == used instead to accomodate the cases when
        # == and eql? are not the same
        def ==(other)
          _equality_with(other)
        end

        # Non-equality
        def !=(other)
          !_equality_with(other)
        end

        # BasicObject is so basic that this part is missing too
        def class
          Proxy
        end

        ##
        # Redirect every method call to the proxied object if the object supports it
        def method_missing(name, *args, &block)
          delegate.respond_to?(name) ? delegate.send(name, *args, &block) : super
        end

        ##
        # It supports every method proxied object supports
        def respond_to_missing?(name, include_private = false)
          delegate.respond_to?(name, include_private)
        end

        ##
        # Type coercion method
        #
        # Type coercion is used for some object types in Ruby like numbers to resolve the
        # problem of rvalue and lvalue when working with two types which should work together.
        # In C++ that would be implemented through typed operator functions.
        def coerce(other)
          [self.class.new(other), delegate]
        end

        ##
        # Abstract constructor
        def initialize(_)
          raise 'Constructor should be re-defined'
        end

        private

        def _equality_with(other)
          equal?(other) ||
            ((self.class == other.class) && (delegate == other.delegate)) ||
            (delegate == other)
        end
      end
    end
  end
end
