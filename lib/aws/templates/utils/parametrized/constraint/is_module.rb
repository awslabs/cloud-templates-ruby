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
            ##
            # Simple check if something is a Module
            class Baseless < self
              include ::Singleton
            end

            ##
            # Checks if passed module is a child of the base
            class Based < self
              attr_reader :base

              def initialize(base)
                _check_if_module(base)
                @base = base
              end

              protected

              def check(_, value, _)
                super
                raise "#{value} is not a child of #{base}" unless value <= base
              end
            end

            def self.with(base)
              base.nil? ? Baseless.instance : Based.new(base)
            end

            protected

            def check(_, value, _)
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
