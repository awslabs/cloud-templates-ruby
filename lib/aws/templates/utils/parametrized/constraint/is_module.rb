require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check if value is a module
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1, constraint: is_module
          #    end
          #
          #    i = Piece.new(:param1 => ::Object)
          #    i.param1 # => ::Object
          #    i = Piece.new(:param1 => 'Bar')
          #    i.param1 # raise ParameterValueInvalid
          class IsModule < self
            as_dsl :module?

            ##
            # Simple check if something is a Module
            class Baseless < self
              def satisfied_by?(other)
                other.is_a?(IsModule)
              end
            end

            ##
            # Checks if passed module is a child of the base
            class Based < self
              attr_reader :base

              def initialize(base)
                _check_if_module(base)
                @base = base
              end

              def satisfied_by?(other)
                other.is_a?(self.class) && (base >= other.base)
              end

              protected

              def check(value, _)
                super
                raise "#{value} is not a child of #{base}" unless value <= base
              end
            end

            def self.create(base = nil)
              base.nil? ? Baseless.new : Based.new(base)
            end

            protected

            def check(value, _)
              _check_if_module(value)
            end

            def _check_if_module(obj)
              raise "#{obj.inspect}(#{obj.class}) is not a Module" unless obj.is_a?(::Module)
            end
          end
        end
      end
    end
  end
end
