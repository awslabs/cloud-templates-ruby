require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Multivariant constraint
          #
          # It is used to perform checks against a list of constraints-functors
          # or lambdas and suceeds when at least one of the nested checks succeed
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1,
          #        :constraint => all_of(
          #          satisfies("Should be extreme") { |v| v > 1000 },
          #          satisfies("Should be moderate") { |v| v < 100 }
          #        )
          #    end
          #
          #    i = Piece.new(:param1 => 200)
          #    i.param1 # raise ParameterValueInvalid with description
          #    i = Piece.new(:param1 => 50)
          #    i.param1 # => 50
          #    i = Piece.new(:param1 => 2000)
          #    i.param1 # => 2000
          #
          class AnyOf < Chain
            using Parametrized::Transformation::Refinements
            using Constraint::Refinements

            def satisfied_by?(other)
              if other.is_a?(self.class)
                constraints.any? do |my_constraint|
                  other.constraints.all? { |constraint| constraint.satisfies?(my_constraint) }
                end
              else
                constraints.any? { |constraint| other.satisfies?(constraint) }
              end
            end

            def satisfies?(other)
              other.nil? || other.satisfied_by?(self) ||
                constraints.all? { |constraint| constraint.satisfies?(other) }
            end

            protected

            def check(value, instance)
              passed = constraints.any? do |c|
                begin
                  instance.instance_exec(value, &c) || true
                rescue RuntimeError
                  false
                end
              end

              raise 'None of the conditions are satisfied' unless passed
            end
          end
        end
      end
    end
  end
end
