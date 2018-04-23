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
          ##
          # Identity concept
          #
          # Empty concept.
          class Empty
            include ::Singleton

            def &(other)
              other
            end

            def process_value(_, value)
              value
            end

            def empty?
              true
            end
          end

          ##
          # Chained concept
          #
          # Concept which consists of a few chained concept as a value processing pipeline.
          class Chain
            attr_reader :concepts

            def initialize(concepts)
              concepts.each { |concept| _check_concept(concept) }
              @concepts = concepts
            end

            def &(other)
              self.class.new(
                if concept.is_as?(self.class)
                  concepts + other.concepts
                else
                  concepts.dup << concept
                end
              )
            end

            def process_value(instance, original_value)
              concepts.inject(original_value) do |value, concept|
                concept.process_value(instance, value)
              end
            end

            def empty?
              false
            end

            private

            def _check_concept(concept)
              return if concept.respond_to?(process_value)
              raise "#{parent.inspect} is not a concept"
            end
          end

          def self.from(obj)
            return Empty.instance if obj.nil?
            return obj if obj.respond_to?(:process_value)
            return with_parameters(obj.to_hash) if obj.respond_to?(:to_hash)
            raise "#{obj.inspect} can't be transformed to a concept"
          end

          def self.with_parameters(transform: nil, constraint: nil)
            return Empty.instance if transform.nil? && constraint.nil?
            new(transform: transform, constraint: constraint)
          end

          attr_reader :transform
          attr_reader :constraint

          def initialize(transform: nil, constraint: nil)
            @transform = _check_transform(transform)
            @constraint = _check_constraint(constraint)
          end

          def process_value(instance, value)
            _check_value(instance, _transform_value(instance, value))
          end

          def &(other)
            Chain.new(self, other)
          end

          def empty?
            false
          end

          private

          def _check_transform(transform)
            return transform if transform.nil? || transform.respond_to?(:to_proc)
            raise "#{transform.inspect} can't be used as transformation"
          end

          def _check_constraint(constraint)
            return constraint if constraint.nil? || constraint.respond_to?(:to_proc)
            raise "#{constraint.inspect} can't be used as constraint"
          end

          def _transform_value(instance, value)
            return value if transform.nil?
            instance.instance_exec(value, &transform)
          end

          def _check_value(instance, value)
            instance.instance_exec(value, &constraint) if constraint
            value
          end
        end
      end
    end
  end
end
