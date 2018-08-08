require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        class Builder
          attr_reader :link

          def apply_concept(concept, instance)
            _create_for(link, instance, concept.transform, concept.constraint)
          end

          def initialize(link)
            @link = link
          end

          private

          def _create_for(link, instance, transform, constraint)
            return LateBound::Values::Empty.new(link) if transform.nil? && constraint.nil?

            ancestor = transform.class.ancestors.find do |mod|
              Builder::Routing.registry.include?(mod)
            end

            raise_cant_find(transform, instance) unless ancestor

            Builder::Routing.registry[ancestor].for(link, instance, transform, constraint)
          end

          def raise_cant_find(transform, instance)
            raise Templates::Exception::ParameterLateBoundException.new(
              transform,
              instance,
              self,
              'Can\'t find late bound value class'
            )
          end
        end
      end
    end
  end
end
