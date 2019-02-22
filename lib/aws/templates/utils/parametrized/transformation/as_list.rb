require 'aws/templates/utils'
require 'set'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Transform input value into a list
          #
          # Input value can be either an array or something which implements
          # to_a method standard semantics. Each list entry is evaluated
          # with specified constraints and transformations.
          #
          # With as_list transformation you can have as many nested levels
          # as it's needed in terms of nested lists or nested objects.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :transform => as_list(
          #        # alias for all elements. Plays a role during introspection
          #        :name => :element,
          #        # description of what the element represents
          #        :description => 'List element',
          #        # constraint for list element
          #        :constraint => not_nil
          #      )
          #      parameter :param2, :transform => as_list(
          #        :name => :element,
          #        :description => 'List element',
          #        :transform => as_list( # nested list
          #          :name => :sub_element,
          #          :description => 'Sub-list element',
          #          :constraint => not_nil
          #        )
          #      )
          #      parameter :param3, :transform => as_list(
          #          :name => :particle,
          #          :description => 'Small particle',
          #          :transform => as_object( # nested object
          #            Aws::Templates::Utils::AsNamed
          #          )
          #        )
          #    end
          #
          #    i = Piece.new(:param1 => [1,2,3])
          #    i.param1 # => [1,2,3]
          #    i = Piece.new(:param1 => [1,nil,3])
          #    i.param1 # throws exception
          #    i = Piece.new(:param2 => [[1],[2],[3]])
          #    i.param2 # => [[1],[2],[3]]
          #    i = Piece.new(:param2 => [1,[2],[3]])
          #    i.param2 # throws exception
          #    i = Piece.new(:param2 => [[1],[nil],[3]])
          #    i.param2 # throws exception
          #    i = Piece.new(:param3 => [{:name => 'Zed'}])
          #    i.param3.first.name # => 'Zed'
          class AsList < self
            attr_reader :sub_parameter

            def unique?
              @is_unique
            end

            def initialize(
              name: nil,
              description: nil,
              transform: nil,
              constraint: nil,
              concept: nil,
              unique: false
            )
              @is_unique = unique

              return if [name, description, transform, constraint].all?(&:nil?)

              @sub_parameter = Parametrized::Parameter.new(
                name || :element,
                description: description,
                concept: concept,
                transform: transform,
                constraint: constraint
              )
            end

            def compatible_with?(other)
              return false unless other.is_a?(self.class)

              (
                sub_parameter.nil? ||
                sub_parameter.concept.compatible_with?(other.sub_parameter.concept)
              ) && (
                !unique? || other.unique?
              )
            end

            protected

            def transform(value, instance)
              return if value.nil?

              raise "#{value.inspect} is not a list" unless value.respond_to?(:to_a)

              result = if sub_parameter
                value.to_a.map { |el| sub_parameter.process_value(instance, el) }
              else
                value.to_a
              end

              _check_for_uniqueness(result) if unique?

              result
            end

            private

            def _check_for_uniqueness(result)
              set = Set.new

              result.each do |element|
                raise "#{element.inspect} is not unique" if set.include?(element)

                set << element
              end
            end
          end
        end
      end
    end
  end
end
