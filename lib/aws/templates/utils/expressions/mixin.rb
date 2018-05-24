module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Expression mixin
        #
        # Adds instance and class methods which allows user to define per-class expressions context.
        #
        # Example:
        #
        #    class A
        #      include Mixin
        #
        #      define_expressions do
        #        variables x: Variables::Arithmetic
        #      end
        #    end
        #
        #    A.expression('x + 1')
        #    A.new.expression { x + 1 }
        module Mixin
          include Utils::Inheritable

          instance_scope do
            def expression(str = nil, &blk)
              self.class.expression(str, &blk)
            end
          end

          class_scope do
            def expressions_definition
              @expressions_definition ||= if superclass < Mixin
                superclass.expressions_definition
              else
                Expressions::Definition.new
              end
            end

            def define_expressions(*args, &blk)
              @expressions_definition = expressions_definition.extend(*args, &blk)
            end

            def expression(str = nil, &blk)
              if str
                @expressions_parser ||= Expressions::Parser.with(expressions_definition)
                @expressions_parser.parse(str)
              else
                @expressions_dsl ||= Expressions::Dsl.new(expressions_definition)
                @expressions_dsl.expression(&blk)
              end
            end
          end
        end
      end
    end
  end
end
