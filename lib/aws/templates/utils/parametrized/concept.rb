require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Type "concept"
        #
        # Type class or concept is a way to express a more refined contract for type. Concept
        # includes type constraint and transformation. Concepts can be chained together to represent
        # increasingly complex transformation and constraints.
        class Concept
          include Utils::Functor

          #TODO: eyebleed. Callback hell's gates
          module Refinements
            refine ::BasicObject do
              def apply_concept(concept, instance)
                return self if concept.nil?
                concept.process_value(instance, self)
              end
            end
          end

          module Processable
            refine ::Proc do
              def compatible_with?(other)
                eql?(other)
              end

              def processable_by?(other)
                other.compatible_with?(self)
              end
            end

            refine ::NilClass do
              def compatible_with?(other)
                true
              end

              def processable_by?(other)
                other.nil? || other.compatible_with?(self)
              end
            end

            using self

            def processable_by?(other)
              other.nil? || other.compatible_with?(self)
            end
          end

          using Refinements
          using Utils::Parametrized::Constraint::Refinements
          using Utils::Parametrized::Transformation::Refinements
          include Processable

          class Definition
            include Utils::Parametrized::Constraint::Dsl
            include Utils::Parametrized::Transformation::Dsl

            def define(transform: nil, constraint: nil)
              {
                transform: transform,
                constraint: constraint
              }
            end
          end

          def self.from(obj = nil, &blk)
            parameters = blk.nil? ? {} : Definition.new.instance_eval(&blk).to_hash

            if obj.nil?
              return Empty.new if parameters.empty?
              return Defined.as(parameters)
            elsif obj.respond_to?(:to_hash)
              return Defined.as(obj.to_hash.merge(parameters))
            elsif obj.respond_to?(:to_proc)
              return obj
            end

            raise "#{obj} is not a concept definition"
          end

          def transform
            nil
          end

          def constraint
            nil
          end

          def empty?
            transform.nil? && constraint.nil?
          end

          def compatible_with?(other)
            return true if empty?
            return false unless other.is_a?(Concept)

            (
              other.transform.processable_by?(transform) &&
              other.constraint.satisfies?(constraint)
            )
          end

          def &(other)
            return self if other.nil? || other.empty?
            return other if empty?
            Chain.for(self, other)
          end

          def invoke(scope, value)
            value.apply_concept(self, scope)
          end

          def process_value(_, value)
            value
          end
        end
      end
    end
  end
end
