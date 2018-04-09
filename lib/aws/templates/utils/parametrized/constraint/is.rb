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
          #      parameter :param1,
          #                constraint: is?(String => { length: satisfies('> 10') { |v| v > 10 } })
          #    end
          #
          #    i = Piece.new(:param1 => '12345678910')
          #    i.param1 # => '12345678910'
          #    i = Piece.new(:param1 => 'Bar')
          #    i.param1 # raise ParameterValueInvalid
          class Is < self
            attr_reader :selector

            def initialize(selector)
              raise "#{selector.inspect} is not a hash" unless selector.respond_to?(:to_hash)
              @selector = selector.to_hash.each_with_object({}) do |(klass, attributes), s|
                _check_if_module(klass)
                s[klass] = attributes && _compose_attributes(klass, attributes)
              end
            end

            protected

            def check(value, _)
              attributes = selector[_find_ancestor(value)]
              _check_attributes(attributes, value) unless attributes.nil?
            end

            private

            def _find_ancestor(obj)
              key = obj.class.ancestors.find { |klass| selector.include?(klass) }
              raise "#{obj.inspect} (#{obj.class}) is not recognized" if key.nil?
              key
            end

            def _compose_attributes(klass, attrs)
              _compose_hash_attributes(
                klass,
                if attrs.respond_to?(:to_hash)
                  attrs.to_hash
                elsif attrs.respond_to?(:to_proc)
                  instance_eval(&attrs)
                else
                  raise "#{attrs} is neither hash nor proc"
                end
              )
            end

            def _compose_hash_attributes(klass, hsh)
              hsh.map do |name, constraint|
                Parametrized::Parameter.new(
                  name,
                  klass || Object,
                  constraint: constraint
                )
              end
            end

            def _check_if_module(obj)
              raise "#{obj.inspect}(#{obj.class}) is not a Module" unless obj.is_a?(::Module)
            end

            def _check_attributes(attributes, obj)
              attributes.each do |attribute|
                attribute.process_value(obj, obj.send(attribute.name))
              end
            end
          end
        end
      end
    end
  end
end
