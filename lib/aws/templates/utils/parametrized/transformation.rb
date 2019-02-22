require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Transformation functor class
        #
        # A transformation is a Proc accepting input value and providing output
        # value which is expected to be a transformation of the input.
        # The proc is executed in instance context so instance methods can
        # be used for calculation.
        #
        # The class implements functor pattern through to_proc method and
        # closure. Essentially, all transformations can be used everywhere where
        # a block is expected.
        #
        # It provides protected method transform which should be overriden in
        # all concrete transformation classes.
        class Transformation
          include Utils::Dsl::Element
          include Utils::Functor
          using Utils::Dependency::Refinements

          # TODO: eyebleed. Callback hell's gates

          ##
          # Transformation adaptors
          #
          # Default method implementations for
          # * BasicObject - adds default transform_as hook implementation which just transforms
          #                 the values with the given transformation
          # * Proc, NilClass - makes the types compatible with test methods of transform class
          module Refinements
            refine ::BasicObject do
              def transform_as(transform, instance)
                return self if transform.nil?

                transform.transform_wrapper(self, instance)
              end
            end

            refine ::Proc do
              def compatible_with?(other)
                eql?(other)
              end

              def processable_by?(other)
                other.compatible_with?(self)
              end
            end

            refine ::NilClass do
              def compatible_with?(_other)
                true
              end

              def processable_by?(other)
                other.nil? || other.compatible_with?(self)
              end
            end
          end

          using Refinements

          def invoke(instance, value)
            value.transform_as(self, instance)
          end

          ##
          # Wraps transformation-dependent method
          #
          # It wraps transformation-dependent "transform" method into a rescue block
          # to standardize exception type and information provided by failed
          # transformation
          # * +value+ - parameter value to be transformed
          # * +instance+ - the instance the value originates from; used for context-dependent
          #                calculations
          def transform_wrapper(value, instance)
            _with_links(transform(value, instance), value)
          rescue StandardError
            raise Templates::Exception::ParameterTransformException.new(self, instance, value)
          end

          def compatible_with?(other)
            eql?(other)
          end

          def processable_by?(other)
            other.compatible_with?(self)
          end

          protected

          ##
          # Transform method
          #
          # * +value+ - parameter value to be transformed
          # * +instance+ - the instance value is transform
          def transform(value, instance); end

          private

          def _with_links(result, input)
            return result if result.equal?(input) || !input.dependency? || input.links.empty?

            result.as_a_dependency.to(input)
          end
        end
      end
    end
  end
end
