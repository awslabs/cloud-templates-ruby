require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check if value matches the regular expression
          #
          # Checks if value matches the regular expression. If value doesn't match, an exception
          # will be thrown with attached description of regular expression and value converted to
          # string.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1, constraint: matches('A+')
          #    end
          #
          #    i = Piece.new(:param1 => 'Ask')
          #    i.param1 # => 'Ask'
          #    i = Piece.new(:param1 => 'Bar')
          #    i.param1 # raise ParameterValueInvalid
          class Matches < self
            attr_reader :expression

            def initialize(rex)
              @expression = Regexp.new(rex)
            end

            def transform_as(transform, _instance)
              #TODO: eyebleed. Tight coupling between transforms and constraints
              transform.is_a?(Parametrized::Transformation::AsString) ? self : nil
            end

            def satisfied_by?(other)
              other.is_a?(self.class) && (expression == other.expression)
            end

            protected

            def check(value, _)
              return if expression =~ value.to_s
              raise "#{value} doesn't match #{expression}"
            end
          end
        end
      end
    end
  end
end
