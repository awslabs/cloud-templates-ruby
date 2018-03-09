require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Dependency
        ##
        # Dependency marker proxy
        #
        # Used internally in the framework to mark an object as potential dependency. There are
        # other alternatives for doing the same like singleton class and reference object.
        # The wrapper is needed when target instance doesn't support singleton classes (Numeric,
        # Symbol, TrueClass, FalseClass, NilClass).
        class Wrapper < BasicObject
          using Dependency::Refinements

          include Utils::Dependency::Depending

          ##
          # Equality
          #
          # Two Dependency objects are equal if it's the same object or if they are pointing to the
          # same target.
          def eql?(other)
            equal?(other) ||
              ((self.class == other.class) && (object == other.object)) ||
              (object == other)
          end

          ##
          # Alias for #eql?
          def ==(other)
            eql?(other)
          end

          # Non-equality
          def !=(other)
            !eql?(other)
          end

          # BasicObject is so basic that this part is missing too
          def class
            Wrapper
          end

          attr_reader :object

          def not_a_dependency
            object
          end

          ##
          # Redirect every method call to the proxied object if the object supports it
          def method_missing(name, *args, &block)
            object.respond_to?(name) ? object.send(name, *args, &block) : super
          end

          ##
          # It supports every method proxied object supports
          def respond_to_missing?(name, include_private = false)
            object.respond_to?(name, include_private)
          end

          ##
          # Type coercion method
          #
          # Type coercion is used for some object types in Ruby like numbers to resolve the
          # problem of rvalue and lvalue when working with two types which should work together.
          # In C++ that would be implemented through typed operator functions.
          def coerce(other)
            [other, object]
          end

          ##
          # Initialize the proxy
          def initialize(source_object)
            @object = source_object.object
            links.merge(source_object.links) if source_object.dependency?
          end
        end
      end
    end
  end
end
