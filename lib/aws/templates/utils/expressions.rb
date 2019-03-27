require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Expressions namespace
      #
      # Expresions framework provides users with DSL and string parser for a simple expressions
      # language. The language supports variables, functions and basic logical and arithmetic
      # operations. Both DSL and string forms of expressions are transformed into a composite of
      # operation objects which can be used for further analysis/execution.
      #
      # Example:
      #
      #    definition = Aws::Templates::Utils::Expressions::Definition.new do
      #      var x: Aws::Templates::Utils::Expressions::Variables::Arithmetic,
      #          y: Aws::Templates::Utils::Expressions::Variables::Arithmetic,
      #          z: Aws::Templates::Utils::Expressions::Variables::Arithmetic
      #
      #      var a: Aws::Templates::Utils::Expressions::Variables::Logical,
      #          b: Aws::Templates::Utils::Expressions::Variables::Logical,
      #          c: Aws::Templates::Utils::Expressions::Variables::Logical
      #    end
      #
      #    dsl = Aws::Templates::Utils::Expressions::Dsl.new(definition)
      #    parser = Aws::Templates::Utils::Expressions::Parser.with(definition)
      #
      #    dsl.expression { x / y * 2 + 1 / z > 5 + z / 3 * 100  }
      #    parser.parse('x / y * 2 + 1 / z > 5 + z / 3 * 100')
      module Expressions
      end
    end
  end
end

# Add flag module into true
class TrueClass
  include Aws::Templates::Utils::Expressions::Flags::Logical
end

# Add flag module into false
class FalseClass
  include Aws::Templates::Utils::Expressions::Flags::Logical
end
