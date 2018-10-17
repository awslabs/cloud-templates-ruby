require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check if the value has specified fields
          #
          # Check if the value has specified fields with values satisfying specified constraints
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #                constraint: has?(length: (satisfies('> 10') { |v| v > 10 }))
          #      parameter :param1,
          #    end
          #
          #    i = Piece.new(:param1 => '12345678910')
          #    i.param1 # => '12345678910'
          #    i = Piece.new(:param1 => 'Bar')
          #    i.param1 # raise ParameterValueInvalid
          class Has < self
            include Utils::Schemed
            using Constraint::Refinements

            as_dsl :has?

            def check_schema(schema)
              schema.each_pair do |field, constraint|
                _raise_wrong_type(field, 'field name') unless field.respond_to?(:to_sym)
                next if constraint.nil?

                _raise_wrong_type(constraint, 'constraint') unless constraint.respond_to?(:to_proc)
              end
            end

            def satisfied_by?(other)
              return false unless other.is_a?(self.class)

              other_schema = other.schema
              schema_keys_set = schema.keys.to_set
              other_schema_keys_set = other_schema.keys.to_set

              return false if schema_keys_set > other_schema_keys_set

              return false unless schema_keys_set <= other_schema_keys_set

              other_schema.all? { |value, constraint| constraint.satisfies?(schema[value]) }
            end

            protected

            def check(value, _instance)
              schema.each_pair do |field, constraint|
                _raise_no_field(value, field) unless value.respond_to?(field)
                next if constraint.nil?

                method = value.method(field)
                _raise_wrong_arity(value, method) if method.arity > 0
                value.instance_exec(value.send(field), &constraint)
              end
            end

            private

            def _raise_wrong_type(obj, correct_type_name)
              raise "#{obj.inspect}(#{obj.class}) is not a #{correct_type_name}"
            end

            def _raise_no_field(obj, field)
              raise "#{obj.inspect}(#{obj.class}) doesn't have field #{field}"
            end

            def _raise_wrong_arity(obj, method)
              raise "#{obj.inspect} method #{method.name} is not a field (arity of #{method.arity})"
            end
          end
        end
      end
    end
  end
end
