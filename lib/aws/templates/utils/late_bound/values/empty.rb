require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          ##
          # Untyped unconstrained late-bound value
          #
          # The values doesn't satisfy any non-nil constraints and not transformable by any
          # transformations (since we don't have any attached type information we can't guarantee
          # it would)
          class Empty < BasicValue
            def self.for(link, _instance, _transform, _constraint)
              new(link)
            end

            def transform_as(transform, instance)
              return self if transform.nil?

              raise Templates::Exception::ParameterLateBoundException.new(
                transform,
                instance,
                self,
                'Expected empty transformation'
              )
            end

            def check_constraint(constraint, instance)
              return if constraint.nil?

              raise Templates::Exception::ParameterLateBoundException.new(
                constraint,
                instance,
                self,
                'Expected empty constraint'
              )
            end
          end
        end
      end
    end
  end
end
