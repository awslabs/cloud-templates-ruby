require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          ##
          # Operation superclass
          #
          # Conrtains basic aspects of operation like op sign and argument wrapping for
          # string formatting. Argument wrapping is used to wrap parts of the expression into
          # parenthesis so the expression can be transformed into string and parsed back without
          # any change in semantics.
          class Operation < Expressions::BasicFunction
            class << self
              def sign_as(str)
                @op_sign = str
              end

              attr_reader :op_sign
            end

            def self.new(*args)
              raise "Operation sign is not defined for #{self}" if op_sign.nil?

              super(*args)
            end

            def to_s
              raise 'Must be overriden'
            end

            protected

            def wrap(arg)
              arg
            end
          end
        end
      end
    end
  end
end
