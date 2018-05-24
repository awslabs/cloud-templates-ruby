require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          module Operations
            ##
            # Operation with one argument
            #
            # Defines initializer with single argument and default string formatting.
            class Unary < Functions::Operation
              def initialize(arg)
                super(arg)
              end

              def to_s
                "#{self.class.op_sign}#{wrap(argument)}"
              end

              protected

              def wrap(arg)
                arg.is_a?(Operations::Operation) ? "(#{arg})" : arg
              end
            end
          end
        end
      end
    end
  end
end
