require 'set'
require 'aws/templates/utils/dependency/object'
require 'aws/templates/utils/dependency/enumerable'

module Aws
  module Templates
    module Utils
      ##
      # Dependency marker proxy
      #
      # Used internally in the framework to mark an object as potential dependency. There are other
      # alternatives for doing the same like singleton class and reference object. There are a few
      # advantages of the approach taken:
      # * Dependency can be used whereever original object is expected
      # * Dependecy can be applied case-by-case basis whereas singleton is attached to the object
      #   itself
      class Dependency < BasicObject
        ##
        # Equality
        #
        # Two Dependency objects are equal if it's the same object or if they are pointing to the
        # same target.
        def ==(other)
          equal?(other) || ((self.class == other.class) && (object == other.object))
        end

        # Non-equality
        def !=(other)
          !(self == other)
        end

        # BasicObject is so basic that this part is missing too
        def class
          Dependency
        end

        # It's a dependency
        def dependency?
          true
        end

        ##
        # List of dependencies
        #
        # It contains just a single entry which is the proxied object.
        def dependencies
          ::Set.new([object])
        end

        attr_reader :object

        ##
        # Redirect every method call to the proxied object if the object supports it
        def method_missing(name, *args, &block)
          object.respond_to?(name) ? object.send(name, *args, &block) : super
        end

        ##
        # It supports every method proxied object supports
        def respond_to_missing?(name, include_private = false)
          object.respond_to?(name, include_private) || super(name, include_private)
        end

        ##
        # Initialize the proxy
        def initialize(target_object)
          @object = target_object
        end
      end
    end
  end
end
