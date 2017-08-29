require 'aws/templates/exceptions'
require 'singleton'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Getter functor class
        #
        # A getter is a Proc without parameters and it is expected to return
        # a value. Since the proc is to be executed in instance context
        # the value can be calculated based on other methods or extracted from
        # options attrribute
        #
        # The class implements functor pattern through to_proc method and
        # closure. Essentially, all getters can be used everywhere where
        # a block is expected.
        #
        # It provides protected method get which should be overriden in
        # all concrete getter classes.
        class Getter
          ##
          # Get options value "as is"
          #
          # Gets value from options attribute by parameter's name without
          # any other operations performed.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => as_is
          #    end
          #
          #    i = Piece.new(:param1 => 3)
          #    i.param1 # => 3
          class AsIs < Getter
            include Singleton

            protected

            def get(parameter, instance)
              instance.options[parameter.name]
            end
          end

          ##
          # Lookup value in options by path
          #
          # Looks up value from options attribute by specified path. The path
          # can be either statically specified or a block can be provided.
          # The block shouldn't have parameters and should return an array
          # containing path. The block will be executed in the instance context.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => path(:a, :b)
          #    end
          #
          #    i = Piece.new(:a => { :b => 3 })
          #    i.param1 # => 3
          class Path < Getter
            attr_reader :path

            def initialize(path)
              unless path.respond_to?(:to_proc) || path.respond_to?(:to_a)
                raise ArgumentError.new(
                  "Path can be either array or Proc: #{path.inspect}"
                )
              end

              @path = path
            end

            protected

            def get(_, instance)
              if path.respond_to?(:to_proc)
                instance.options[*instance.instance_eval(&path)]
              elsif path.respond_to?(:to_a)
                instance.options[*path]
              end
            end
          end

          ##
          # Calculate value
          #
          # If a block is specified, it will be executed in the instance
          # context and return will be used as parameter value. If a value
          # specified then it will be used as parameter value instead.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => value(1)
          #      parameter :param2, :getter => value { options[:z] + 1 }
          #    end
          #
          #    i = Piece.new(:z => 3)
          #    i.param2 # => 4
          #    i.param1 # => 1
          class Value < Getter
            attr_reader :calculation

            def initialize(calculation)
              @calculation = calculation
            end

            protected

            def get(_, instance)
              if calculation.respond_to?(:to_proc)
                instance.instance_eval(&calculation)
              else
                calculation
              end
            end
          end

          ##
          # Pick one of non-nil values returned by nested getters
          #
          # In general it plays the same role as || operator in Ruby. It
          # just picks first non-nil value returned by a list of getters
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => one_of(
          #        path(:a, :b),
          #        path(:b, :c)
          #      )
          #    end
          #
          #    i = Piece.new( :a => { :b => 3 } )
          #    i.param1 # => 3
          #    i = Piece.new( :b => { :c => 4 } )
          #    i.param1 # => 4
          class OneOf < Getter
            attr_reader :getters

            def initialize(getters)
              @getters = getters
            end

            protected

            def get(parameter, instance)
              getters.inject(nil) do |value, g|
                value = instance.instance_exec(parameter, &g)
                break value unless value.nil?
              end
            end
          end

          ##
          # Creates closure with getter invocation
          #
          # It's an interface method required for Getter to expose
          # functor properties. It encloses invocation of Getter get_wrapper
          # method into a closure. The closure itself is executed in the context
          # of Parametrized instance which provides proper set "self" variable.
          #
          # The closure itself accepts 1 parameters
          # * +parameter+ - the Parameter object which the getter is executed for
          # ...where instance is assumed from self
          def to_proc
            getter = self

            lambda do |parameter|
              getter.get_wrapper(parameter, self)
            end
          end

          ##
          # Wraps getter-dependent method
          #
          # It wraps constraint-dependent "get" method into a rescue block
          # to standardize exception type and information provided by failed
          # value calculation
          # * +parameter+ - the Parameter object which the getter is executed for
          # * +instance+ - the instance value is taken from
          def get_wrapper(parameter, instance)
            get(parameter, instance)
          rescue
            raise NestedParameterException.new(parameter)
          end

          protected

          ##
          # Getter method
          #
          # * +parameter+ - the Parameter object which the getter is executed for
          # * +instance+ - the instance value is taken from
          def get(parameter, instance); end
        end

        ##
        # Syntax sugar for getters definition
        #
        # It injects the methods as class-scope methods into mixing classes.
        # The methods are factories to create particular type of getter
        module ClassMethods
          def delegation
            Getter::Delegate.new
          end

          ##
          # Get parameter from Options as is
          #
          # alias for AsIs class
          def as_is
            Getter::AsIs.instance
          end

          ##
          # Calculate value of parameter
          #
          # alias for Value class
          def value(v = nil, &blk)
            Getter::Value.new(v.nil? ? blk : v)
          end

          ##
          # Look up value of the parameter with path
          #
          # alias for Path class
          def path(*v, &blk)
            Getter::Path.new(
              v.empty? ? blk : v
            )
          end

          ##
          # Choose one non-nil value from nested getters
          #
          # alias for OneOf class
          def one_of(*getters)
            Getter::OneOf.new(getters)
          end
        end
      end
    end
  end
end
