require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Dependency
        ##
        # Dependency attachment common mechanism
        #
        # The module defines common methods to attach dependencies to objects.
        module Depending
          using Dependency::Refinements

          include ::Aws::Templates::Utils::Inspectable

          # It's a dependency
          def dependency?
            true
          end

          # mark the object as dependency
          def as_a_dependency
            self
          end

          ##
          # Add dependency
          #
          # Add a link to the target to the current Dependency object
          def to(target)
            if target.dependency?
              links.merge(target.links)
            else
              links << target
            end

            self
          end

          ##
          # Set dependency to the target
          def to_self
            to(object)
          end

          ##
          # Dependency set
          def links
            @links ||= ::Set.new
          end

          ##
          # Link the value to the source
          #
          # Links source or result of calculation of the block to the target object of the
          # dependency. The mecahanism is a middle ground between extreme case of indefinite
          # recursive dependency propagation and no propagation at all
          #
          #    some_artifact.as_a_dependency.with { some_attribute }
          #    # => Dependency(@object = <some_attribute value>, <link to some_artifact>)
          def with(source = nil, &source_calculation_block)
            value = if source_calculation_block.nil?
              source
            else
              object.instance_exec(&source_calculation_block)
            end

            value.as_a_dependency.to(self)
          end

          ##
          # Target object
          def object
            raise 'The method should be overriden'
          end

          ##
          # Object without any dependencies attached
          def not_a_dependency
            object
          end
        end
      end
    end
  end
end
