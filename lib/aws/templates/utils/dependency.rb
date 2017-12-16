require 'aws/templates/utils'

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
        using Refinements

        include ::Aws::Templates::Utils::Inspectable

        ##
        # Equality
        #
        # Two Dependency objects are equal if it's the same object or if they are pointing to the
        # same target.
        def eql?(other)
          equal?(other) || ((self.class == other.class) && (object == other.object))
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
          Dependency
        end

        # It's a dependency
        def dependency?
          true
        end

        # mark the object as dependency
        def as_a_dependency
          self
        end

        attr_reader :object
        attr_reader :dependencies

        alias not_a_dependency object

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
        # Add dependency
        #
        # Add a link to the target to the current Dependency object
        def to(target)
          if target.dependency?
            dependencies.merge(target.dependencies)
          else
            dependencies << target
          end

          self
        end

        ##
        # Link the value to the source
        #
        # Links source or result of calculation of the block to the target object of the dependency.
        # The mecahanism is a middle ground between extreme case of indefinite recursive dependency
        # propagation and no propagation at all
        #
        #    some_artifact.as_a_dependency.with { some_attribute }
        #    # => Dependency(@object = <some_attribute value>, <link to some_artifact>)
        def with(source = nil, &source_calculation_block)
          value = if source_calculation_block.nil?
            source
          else
            object.instance_exec(value, &source_calculation_block)
          end

          value.as_a_dependency.to(self)
        end

        ##
        # Set dependency to the target
        def to_self
          to(object)
        end

        ##
        # Initialize the proxy
        def initialize(source_object)
          @object = source_object.object

          @dependencies = if source_object.dependency?
            source_object.dependencies.dup
          else
            ::Set.new
          end
        end
      end
    end
  end
end
