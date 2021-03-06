require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check if value is of specified type(s)
          #
          # Checks if the value is of kind of one of the modules specified in the selector and check
          # the value against constraint specified in this particular selector entry.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #                constraint: is?(
          #                  String => (satisfies('length > 10') { |v| v.length > 10 })
          #                )
          #      parameter :param1,
          #    end
          #
          #    i = Piece.new(:param1 => '12345678910')
          #    i.param1 # => '12345678910'
          #    i = Piece.new(:param1 => 'Bar')
          #    i.param1 # raise ParameterValueInvalid
          class Is < self
            include Utils::Schemed
            using Constraint::Refinements

            as_dsl :is?

            def check_schema(schema)
              schema.each_pair do |obj, c|
                raise "#{obj.inspect}(#{obj.class}) is not a Module" unless obj.is_a?(::Module)
                next if c.nil?
                raise "#{c.inspect}(#{c.class}) is not a proc" unless c.respond_to?(:to_proc)
              end
            end

            def satisfied_by?(other)
              return false unless other.is_a?(self.class)

              modules = schema.keys.to_set

              other.schema.all? do |type, constraint|
                type
                  .ancestors
                  .select { |mod| modules.include?(mod) }
                  .any? { |anchor| constraint.satisfies?(schema[anchor]) }
              end
            end

            protected

            def check(value, instance)
              constraint = schema[_find_ancestor(value)]
              instance.instance_exec(value, &constraint) unless constraint.nil?
            end

            private

            def _find_ancestor(obj)
              key = obj.class.ancestors.find { |klass| schema.include?(klass) }

              _raise_no_match(obj) if key.nil?

              key
            end

            def _raise_no_match(obj)
              raise "#{obj.inspect} has invalid type #{obj.class} (not a child of #{schema.keys})"
            end
          end
        end
      end
    end
  end
end
