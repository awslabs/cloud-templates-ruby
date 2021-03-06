require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Aggregate constraint
          #
          # It is used to perform checks against a list of constraints-functors
          # or lambdas.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1,
          #        :constraint => all_of(
          #          not_nil,
          #          satisfies("Should be moderate") { |v| v < 100 }
          #        )
          #    end
          #
          #    i = Piece.new(:param1 => nil)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 200)
          #    i.param1 # raise ParameterValueInvalid with description
          #    i = Piece.new(:param1 => 50)
          #    i.param1 # => 50
          class AllOf < Chain
            using Parametrized::Transformation::Refinements
            using Constraint::Refinements

            def satisfied_by?(other)
              if other.is_a?(self.class)
                constraints.all? do |my_constraint|
                  other.constraints.any? { |constraint| constraint.satisfies?(my_constraint) }
                end
              else
                constraints.all? { |constraint| other.satisfies?(constraint) }
              end
            end

            def satisfies?(other)
              other.nil? || other.satisfied_by?(self) ||
                constraints.any? { |constraint| constraint.satisfies?(other) }
            end

            protected

            def check(value, instance)
              constraints.each { |c| instance.instance_exec(value, &c) }
            end
          end
        end
      end
    end
  end
end
