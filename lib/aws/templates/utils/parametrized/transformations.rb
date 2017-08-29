require 'aws/templates/exceptions'
require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/nested'
require 'aws/templates/utils/parametrized/mapper'
require 'singleton'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Transformation functor class
        #
        # A transformation is a Proc accepting input value and providing output
        # value which is expected to be a transformation of the input.
        # The proc is executed in instance context so instance methods can
        # be used for calculation.
        #
        # The class implements functor pattern through to_proc method and
        # closure. Essentially, all transformations can be used everywhere where
        # a block is expected.
        #
        # It provides protected method transform which should be overriden in
        # all concrete transformation classes.
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
          class AsObject < Transformation
            attr_reader :klass

            def initialize(klass = nil, &definition)
              @klass = if klass.nil?
                Nested.create_class
              elsif klass.is_a?(Class)
                klass
              elsif klass.is_a?(Module)
                Nested.create_class.with(klass)
              else
                raise "#{klass} is neither a class nor a module"
              end

              @klass.instance_eval(&definition) unless definition.nil?
            end

            protected

            def transform(_, value, _)
              return if value.nil?
              klass.new(
                if Utils.hashable?(value)
                  value
                elsif Utils.parametrized?(value)
                  Mapper.new(value)
                else
                  raise "Value #{value} doesn't have parameters"
                end
              )
            end
          end

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
          class AsList < Transformation
            attr_reader :sub_parameter

            def initialize(klass = nil, options = nil)
              return if options.nil?

              @sub_parameter = Parameter.new(
                options[:name],
                klass,
                description: options[:description],
                transform: options[:transform],
                constraint: options[:constraint]
              )
            end

            protected

            def transform(parameter, value, instance)
              return if value.nil?

              unless value.respond_to?(:to_a)
                raise "#{parameter.name} is assigned to " \
                  "#{value.inspect} which is not a list"
              end

              if sub_parameter
                value.to_a.map { |el| sub_parameter.process_value(instance, el) }
              else
                value.to_a
              end
            end
          end

          ##
          # Transform value with the specified render
          #
          # Input value can be anything which could be rendered by the
          # specified render type. Returned value is rendered input.
          #
          # The transformation is useful when you have a document of some
          # format embedded into a document of another format. An example
          # could be Bash scripts embedded into AWS CFN template.
          #
          # === Example
          #
          #    class Brush
          #      attr_reader :color
          #      attr_reader :thickness
          #      attr_reader :type
          #
          #      def initialize(c, thick, t)
          #        @c = c
          #        @thick = thick
          #        @t = t
          #      end
          #    end
          #
          #    class Circle
          #      attr_reader :radius
          #      attr_reader :brush
          #
          #      def initialize(r, b)
          #        @radius = r
          #        @brush = b
          #      end
          #    end
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :picture, :transform => as_rendered(
          #        # Render Type
          #        Graphics::Renders::JPEG,
          #        # parameter section for the render
          #        format: :base64
          #      )
          #    end
          #
          #    i = Piece.new(picture: Circle.new(10, Brush.new(:red, 2, :dots)))
          #    i.picture # => <rendered representation>
          class AsRendered < Transformation
            attr_reader :type
            attr_reader :parameters

            def initialize(render_type, params)
              @type = _check_render_type(render_type)
              @parameters = params
            end

            protected

            def transform(_, value, instance)
              return if value.nil?
              type.view_for(value, _compute_render_parameters(instance)).to_rendered
            end

            private

            def _check_render_type(render_type)
              unless render_type.respond_to?(:view_for)
                raise(
                  "Wrong render type object #{params}. " \
                  'The instance should have #view_for method.'
                )
              end

              render_type
            end

            def _compute_render_parameters(instance)
              return if parameters.nil?

              if parameters.respond_to?(:to_proc)
                instance.instance_exec(&parameters)
              else
                parameters
              end
            end
          end

          ##
          # Convert input into integer
          #
          # Input value can be anything implementing :to_i method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_integer
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => '23')
          #    i.param # => 23
          class AsInteger < Transformation
            include Singleton

            protected

            def transform(_, value, _)
              return if value.nil?
              Integer(value)
            end
          end

          ##
          # Convert input into string
          #
          # Input value can be anything implementing :to_s method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_string
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => 23)
          #    i.param # => '23'
          class AsString < Transformation
            include Singleton

            protected

            def transform(_, value, _)
              return if value.nil?
              String(value)
            end
          end

          ##
          # Convert input into boolean
          #
          # Input value can be anything implementing :to_s method. Value considered false if it is:
          # * +'false' as a string+
          # * +FalseClass+
          # Otherwise, value is true. If value is nil, it won't be replaced by "false"
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_boolean
          #    end
          #
          #    i = Piece.new
          #    i.param # => false
          #    i = Piece.new(:param => 0)
          #    i.param # => true
          class AsBoolean < Transformation
            include Singleton

            protected

            def transform(_, value, _)
              return if value.nil?
              !value.to_s.casecmp('false').zero?
            end
          end

          ##
          # Convert input into hash
          #
          # Input value can be anything implementing :to_hash method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_hash
          #      parameter :param2,
          #        transform: as_hash {
          #          value name: :number,
          #            description: 'Number',
          #            constraint: not_nil,
          #            transform: as_integer
          #        }
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => [[1,2]])
          #    i.param # => {1=>2}
          #    i = Piece.new(:param2 => [[1,'3']])
          #    i.param # => {1=>3}
          class AsHash < Transformation
            include ClassMethods

            def key(opts)
              @key_parameter = _create_parameter(opts)
            end

            def value(opts)
              @value_parameter = _create_parameter(opts)
            end

            def initialize(klass = nil, &blk)
              @klass = klass
              instance_eval(&blk) if blk
            end

            protected

            def transform(_, value, instance)
              return if value.nil?

              Hash[
                Hash[value].map do |k, v|
                  [
                    _process_value(@key_parameter, instance, k),
                    _process_value(@value_parameter, instance, v)
                  ]
                end
              ]
            end

            def _process_value(parameter, instance, value)
              return value if parameter.nil?
              parameter.process_value(instance, value)
            end

            private

            def _create_parameter(opts)
              Parameter.new(
                opts[:name],
                @klass,
                description: opts[:description],
                transform: opts[:transform],
                constraint: opts[:constraint]
              )
            end
          end

          ##
          # Convert to a Ruby class
          #
          # The transformation allows to use elements of metaprogramming in the framework. It
          # tries to transform passed value to a Ruby class.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_module
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => 'Object')
          #    i.param # => Object
          class AsModule < Transformation
            include Singleton

            protected

            def transform(_, value, _)
              return if value.nil?
              return value if value.is_a?(Module)
              return _lookup(value.to_s) if value.respond_to?(:to_s)
              raise "#{value} can't be transformed to a class"
            end

            private

            PATH_REGEXP = Regexp.compile('::|[.]|/')

            def _lookup(class_name)
              target = class_name.split(PATH_REGEXP)
                                 .inject(::Kernel) { |acc, elem| acc.const_get(elem) }

              raise "#{class_name} == #{target} which is not a class" unless target.is_a?(Module)

              target
            end
          end

          ##
          # Creates closure with transformation invocation
          #
          # It's an interface method required for Transformation to expose
          # functor properties. It encloses invocation of Transformation
          # transform_wrapper method into a closure. The closure itself is
          # executed in the context of Parametrized instance which provides
          # proper set "self" variable.
          #
          # The closure itself accepts 2 parameters:
          # * +parameter+ - the Parameter object which the transformation
          #                 will be performed for
          # * +value+ - parameter value to be transformed
          # ...where instance is assumed from self
          def to_proc
            transform = self

            lambda do |parameter, value|
              transform.transform_wrapper(parameter, value, self)
            end
          end

          ##
          # Wraps transformation-dependent method
          #
          # It wraps constraint-dependent "transform" method into a rescue block
          # to standardize exception type and information provided by failed
          # transformation calculation
          # * +parameter+ - the Parameter object which the transformation will
          #                 be performed for
          # * +value+ - parameter value to be transformed
          # * +instance+ - the instance value is transform
          def transform_wrapper(parameter, value, instance)
            transform(parameter, value, instance)
          rescue
            raise NestedParameterException.new(parameter)
          end

          protected

          ##
          # Transform method
          #
          # * +parameter+ - the Parameter object which the transformatio is
          #                 performed for
          # * +value+ - parameter value to be transformed
          # * +instance+ - the instance value is transform
          def transform(parameter, value, instance); end
        end

        ##
        # Syntax sugar for transformations definition
        #
        # It injects the methods as class-scope methods into mixing classes.
        # The methods are factories to create particular type of transformation
        module ClassMethods
          ##
          # Transform the value into an object
          #
          # alias for AsObject class
          def as_object(klass = nil, &definition)
            Transformation::AsObject.new(klass, &definition)
          end

          ##
          # Transform the value into a list
          #
          # alias for AsList class
          def as_list(parameters = nil)
            Transformation::AsList.new(self, parameters)
          end

          ##
          # Transform value with the specified render
          #
          # alias for AsRendered class
          def as_rendered(render_type, params = nil, &params_block)
            Transformation::AsRendered.new(render_type, params || params_block)
          end

          ##
          # Convert input into integer
          #
          # alias for AsInteger class
          def as_integer
            Transformation::AsInteger.instance
          end

          ##
          # Convert input into string
          #
          # alias for AsString class
          def as_string
            Transformation::AsString.instance
          end

          ##
          # Convert input into boolean
          #
          # alias for AsBoolean class
          def as_boolean
            Transformation::AsBoolean.instance
          end

          ##
          # Convert input into hash
          #
          # alias for AsHash class
          def as_hash(&blk)
            Transformation::AsHash.new(self, &blk)
          end

          ##
          # Convert input into a class
          #
          # alias for AsModule class
          def as_module
            Transformation::AsModule.instance
          end
        end
      end
    end
  end
end
