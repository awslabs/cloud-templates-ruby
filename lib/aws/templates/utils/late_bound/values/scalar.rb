require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          ##
          # Simple scalar late-bound value
          #
          # Contains transformation and constraint attached. Does simple equality checks for both
          # while getting checked and transformed.
          class Scalar < Value
            using Utils::Parametrized::Transformation::Refinements

            attr_reader :transform

            def self.for(link, _instance, transform, constraint)
              new(link, transform, constraint)
            end

            def initialize(link, transform, constraint)
              super(link, constraint)
              @transform = transform
            end

            def transform_as(other_transform, instance)
              return self if transform.processable_by?(other_transform)

              raise Templates::Exception::ParameterLateBoundException.new(
                other_transform,
                instance,
                self,
                "Late bound (#{transform}) is not processable by the target transform"
              )
            end
          end
        end
      end
    end
  end
end
