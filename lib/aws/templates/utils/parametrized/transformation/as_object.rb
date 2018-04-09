require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Transform input value into the object
          #
          # Input value can be either hash or object. The transformation performs
          # nested object evaluation recusrsively as the input were Parametrized
          # instance. As a parameter for the transformation you can
          # specify either Module which mixes in Parametrized or to use
          # a block which is to be evaluated as a part of Parametrized definition
          # or both.
          #
          # With as_object transformation you can have as many nested levels
          # as it's needed.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1,
          #        :transform => as_object(Aws::Templates::Utils::AsNamed)
          #      parameter :param2, :transform => as_object {
          #        parameter :id, :description => 'Just ID',
          #          :constraint => not_nil
          #      }
          #      parameter :param3,
          #        :transform => as_object(Aws::Templates::Utils::AsNamed) {
          #          parameter :path, :description => 'Just path',
          #            :constraint => not_nil
          #        }
          #    end
          #
          #    i = Piece.new
          #    i.param1 # => nil
          #    i = Piece.new(:param1 => {:name => 'Zed'})
          #    i.param1.name # => 'Zed'
          #    i = Piece.new(:param2 => {:id => 123})
          #    i.param2.id # => 123
          #    i = Piece.new(:param3 => {:path => 'a/b', :name => 'Rex'})
          #    i.param3.path # => 'a/b'
          #    i.param3.name # => 123
          class AsObject < self
            attr_reader :klass

            def initialize(scope, klass = nil, &definition)
              @klass = if klass.nil?
                Parametrized::Nested.create_class(scope)
              elsif klass.is_a?(Class)
                klass
              elsif klass.is_a?(Module)
                Parametrized::Nested.create_class(scope).with(klass)
              else
                raise "#{klass} is neither a class nor a module"
              end

              @klass.class_eval(&definition) unless definition.nil?
            end

            def transform(value, instance)
              return if value.nil?
              klass.new(instance, value)
            end
          end
        end
      end
    end
  end
end
