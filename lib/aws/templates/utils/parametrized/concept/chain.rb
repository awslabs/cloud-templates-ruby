require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Concept
          class Chain
            include Utils::Functor
            using Concept::Processable

            attr_reader :concepts

            def self.for(*args)
              concepts = args
                .flatten
                .map { |concept| concept.is_a?(self) ? concept.concepts : concept }

              concepts.flatten!
              concepts.reject!(&:empty?)

              return Concept::Empty.new if concepts.empty?

              return concepts.first if concepts.size == 1

              Chain.new(concepts)
            end

            def initialize(concepts)
              @concepts = concepts
            end

            def empty?
              false
            end

            def compatible_with?(other)
              concepts.all? { |concept| other.processable_by?(concept) }
            end

            def processable_by?(other)
              concepts.all? { |concept| concept.processable_by?(other) }
            end

            def &(other)
              return other if empty?
              return self if other.empty?

              Chain.for(self, other)
            end

            def invoke(scope, value)
              process_value(scope, value)
            end

            def process_value(instance, value)
              concepts.inject(value) { |memo, concept| instance.instance_exec(memo, &concept) }
            end
          end
        end
      end
    end
  end
end
