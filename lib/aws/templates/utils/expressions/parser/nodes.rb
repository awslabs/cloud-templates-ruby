require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Parser
          ##
          # Syntax node classes
          #
          # The PEG grammar defined for the expressions language are wired to the Syntax node
          # classes to define processing routines right inside of the grammar itself. The core
          # processing routing is to_dsl method which transforms (recursively if necessary)
          # syntax node into corresponding DSL object.
          module Nodes
            ##
            # "Clean" node
            #
            # It means that the node contains actual structural information and can't be collated.
            module Clean
              def clean
                self
              end
            end

            ##
            # Operation part
            #
            # Is a node which contains information about another step in chained operation.
            #
            # Example:
            #
            #    "x + y + 1" => ('x', part('+', 'y'), part('+', '1'))
            #
            class Part < Treetop::Runtime::SyntaxNode
              def op
                _op.text_value
              end

              def argument
                _argument.clean
              end
            end

            ##
            # Wrapper node
            #
            # Examples of pure wrappers in syntaxis are: parenthesis, grouping nodes, etc
            class Wrapper < Treetop::Runtime::SyntaxNode
              def clean
                _argument.clean
              end
            end

            ##
            # Logical negation node
            #
            # Examples:
            #
            #    !x => negation('x')
            class Negation < Treetop::Runtime::SyntaxNode
              def clean
                self
              end

              def argument
                _argument.clean
              end

              def to_dsl(definition)
                Expressions::Functions::Operations::Logical::Not.new(argument.to_dsl(definition))
              end
            end

            # Comparison node
            class Comparison < Treetop::Runtime::SyntaxNode
              COMPARISONS = {
                '>' => Expressions::Functions::Operations::Comparisons::Greater,
                '<' => Expressions::Functions::Operations::Comparisons::Less,
                '>=' => Expressions::Functions::Operations::Comparisons::GreaterOrEqual,
                '<=' => Expressions::Functions::Operations::Comparisons::LessOrEqual,
                '==' => Expressions::Functions::Operations::Comparisons::Equal,
                '!=' => Expressions::Functions::Operations::Comparisons::NotEqual,
                '!~' => Expressions::Functions::Operations::Range::Outside,
                '=~' => Expressions::Functions::Operations::Range::Inside
              }.freeze

              def clean
                return left if _right.empty?
                self
              end

              def op
                _right._op.text_value
              end

              def left
                _left.clean
              end

              def right
                _right._argument.clean
              end

              def to_dsl(definition)
                COMPARISONS[op].new(left.to_dsl(definition), right.to_dsl(definition))
              end
            end

            # General operation node
            class Operation < Treetop::Runtime::SyntaxNode
              OPERATIONS = {
                '|' => Expressions::Functions::Operations::Logical::Or,
                '&' => Expressions::Functions::Operations::Logical::And,
                '+' => Expressions::Functions::Operations::Arithmetic::Addition,
                '-' => Expressions::Functions::Operations::Arithmetic::Subtraction,
                '*' => Expressions::Functions::Operations::Arithmetic::Multiplication,
                '/' => Expressions::Functions::Operations::Arithmetic::Division
              }.freeze

              def clean
                return _left.clean if _rest.empty?
                self
              end

              def get_first(definition)
                right = _rest.elements.first

                OPERATIONS[right.op].new(
                  _left.clean.to_dsl(definition),
                  right.argument.to_dsl(definition)
                )
              end

              def to_dsl(definition)
                _rest.elements[1..-1].inject(get_first(definition)) do |op, element|
                  OPERATIONS[element.op].new(op, element.argument.to_dsl(definition))
                end
              end
            end

            # Boolean literal
            class BooleanLiteral < Treetop::Runtime::SyntaxNode
              include Clean

              def to_dsl(_definition)
                _argument.text_value == 'true'
              end
            end

            # Function node
            class Function < Treetop::Runtime::SyntaxNode
              include Clean

              def name
                _name.to_sym
              end

              def to_dsl(definition)
                arguments = if _first.empty?
                  []
                else
                  [_first.clean.to_dsl(definition)].concat(
                    _rest.elements.map do |element|
                      element._argument.clean.to_dsl(definition)
                    end
                  )
                end

                definition.instantiate(name, *arguments)
              end
            end

            # Variable node
            class Variable < Treetop::Runtime::SyntaxNode
              include Clean

              def to_dsl(definition)
                definition.instantiate(_name.to_sym)
              end
            end

            # Identifier
            class Identifier < Treetop::Runtime::SyntaxNode
              def to_sym
                text_value.to_sym
              end
            end

            # Integer literal
            class IntegerLiteral < Treetop::Runtime::SyntaxNode
              include Clean

              def to_dsl(_definition)
                text_value.to_i
              end
            end

            # Float literal
            class FloatLiteral < Treetop::Runtime::SyntaxNode
              include Clean

              def to_dsl(_definition)
                text_value.to_f
              end
            end

            # String literal
            class StringLiteral < Treetop::Runtime::SyntaxNode
              include Clean

              def to_dsl(_definition)
                _content.text_value.to_s
              end
            end
          end
        end
      end
    end
  end
end
