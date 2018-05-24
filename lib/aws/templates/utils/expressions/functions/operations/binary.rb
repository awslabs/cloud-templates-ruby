require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          module Operations
            ##
            # Abstract operation with two arguments
            #
            # It defines two-values initializer and string formatting
            class Binary < Functions::Operation
              def initialize(left, right)
                super(left, right)
              end

              def to_s
                "#{wrap(left)}#{self.class.op_sign}#{wrap(right)}"
              end
            end
          end
        end
      end
    end
  end
end
