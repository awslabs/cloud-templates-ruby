require 'aws/templates/utils'

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

            def initialize(klass = nil, options = nil)
              return if options.nil?

              @sub_parameter = Parametrized::Parameter.new(
                options[:name],
                klass,
                description: options[:description],
                transform: options[:transform],
                constraint: options[:constraint]
              )
            end

            def transform(value, instance)
              return if value.nil?

              raise "#{value.inspect} is not a list" unless value.respond_to?(:to_a)

              if sub_parameter
                value.to_a.map { |el| sub_parameter.process_value(instance, el) }
              else
                value.to_a
              end
            end
          end
        end
      end
    end
  end
end
