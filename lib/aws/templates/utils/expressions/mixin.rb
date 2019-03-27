module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Expression mixin
        #
        # Adds instance and class methods which allows user to define expressions.
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
          ##
          # Expression wrapper
          #
          # Simple adapter which wraps objects or code blocks. In some parts of the framework usage
          # of Proc objects is already reserved and hence the need to wrap the code blocks with DSL
          # expresions so they are not misinterpreted. It's not visible to the end user.
          class Wrapper
            using Expressions::Refinements

            attr_reader :target

            def initialize(obj = nil, &blk)
              @target = obj || blk
            end

            def to_expression_by(definition)
              target.to_expression_by(definition)
            end
          end

          include Utils::Inheritable

          instance_scope do
            def expression(str = nil, &blk)
              self.class.expression(str, &blk)
            end
          end

          class_scope do
            def expression(str = nil, &blk)
              Mixin::Wrapper.new(str, &blk)
            end
          end
        end
      end
    end
  end
end
