require 'aws/templates/exceptions'
require 'aws/templates/utils/parametrized/guarded'
require 'aws/templates/utils/inheritable'
require 'aws/templates/utils/dependent'
require 'aws/templates/utils/inspectable'
require 'set'

module Aws
  module Templates
    module Utils
      ##
      # 'parameter' DSL to specify artifact parameters checks
      #
      # The module provides the basic class-level methods to define
      # so-called parameters. A parameter is a reader-like method of
      # value extraction, constraints checking and transformation. Essentially,
      # it's domain-specific extended implementation of attr_reader.
      module Parametrized
        include Guarded
        include Dependent
        include Inheritable
        include Inspectable

        ##
        # Parameter object
        #
        # The object incorporates parameter specification and basic logic for
        # value extraction, checking and transformation.  Parameter objects
        # are created at each parameter description.
        class Parameter
          attr_reader :name
          attr_accessor :description

          def getter(instance = nil)
            @getter || (
              instance &&
              (
                (instance.respond_to?(:getter) && instance.getter) ||
                (instance.class.respond_to?(:getter) && instance.class.getter)
              )
            )
          end

          attr_accessor :transform
          attr_accessor :constraint
          attr_accessor :klass

          ##
          # Create a parameter object with given specification
          #
          # * +name+ - parameter name
          # * +enclosing_class+ - the class the parameter was declared at
          # * +specification+ - parameter specification; it includes:
          # ** +:description+ - human-readable parameter description
          # ** +:getter+ - getter Proc which will be used for parameter extraction
          #                from input hash or plain value. The Proc shouldn't
          #                expect any arguments and it will be executed in
          #                the instance context. If a plain value is passed
          #                it will be used as is. If the argument is not specified
          #                then value will be extracted from the input hash by
          #                the parameter name (see Getter for more information)
          # ** +:transform+ - transform Proc which will be used for transforming
          #                   extracted value. It should expect single parameter
          #                   and it will be executed in instance context.
          #                   if not specified not transformation will be
          #                   performed (see Transformation for more information)
          # ** +:constraint+ - constraint Proc which will be used to check
          #                    the value after transformation step. The Proc
          #                    is expected to receive one arg and throw an
          #                    exception if constraints are not met
          #                    (see Constraint for more information)
          def initialize(name, enclosing_class, specification = {})
            @name = name
            set_specification(enclosing_class, specification)
          end

          ##
          # Get the parameter value from the instance
          #
          # It is used internally in auto-generated accessors to get the value
          # from input hash. The method extracts value from the hash and
          # pushes it through transformation and constraint stages. Also,
          # you can specify value as the optional parameter so getter even
          # if present will be ignored. It relies on presence of options
          # accessor in the instance.
          # * +instance+ - instance to extract the parameter value from
          def get(instance)
            process_value(instance, extract_value(instance))
          end

          def process_value(instance, value)
            value = instance.instance_exec(self, value, &transform) if transform
            instance.instance_exec(self, value, &constraint) if constraint
            value
          end

          private

          def extract_value(instance)
            raise ParameterGetterIsNotDefined.new(self) unless getter(instance)
            execute_getter(instance, getter(instance))
          end

          def execute_getter(instance, getter)
            if getter.respond_to?(:to_hash)
              getter
            elsif getter.respond_to?(:to_proc)
              instance.instance_exec(self, &getter)
            else
              getter
            end
          end

          ALLOWED_SPECIFICATION_ENTRIES = Set.new %i[description getter transform constraint]

          def set_specification(enclosing_class, specification) # :nodoc:
            @klass = enclosing_class

            wrong_options = specification.keys.reject do |option_name|
              ALLOWED_SPECIFICATION_ENTRIES.include?(option_name)
            end

            raise_wrong_options(wrong_options) unless wrong_options.empty?

            process_specification(specification)
          end

          def raise_wrong_options(wrong_options)
            raise ParameterSpecificationIsInvalid.new(self, wrong_options)
          end

          def process_specification(spec)
            @description = spec[:description] if spec.key?(:description)
            @getter = spec[:getter] if spec.key?(:getter)
            @transform = spec[:transform] if spec.key?(:transform)
            @constraint = spec[:constraint] if spec.key?(:constraint)
          end
        end

        ##
        # Makes parametrized accessible as recursive concept
        class RecursiveAdapter
          attr_reader :target

          ##
          # Defined hash keys
          def keys
            target.parameter_names.merge(target.options.keys)
          end

          ##
          # Index operator
          #
          # Performs intermediate transformation of value if needed (if value is a lambda) and
          # returns it wrapping into Definition instance with the same context if needed
          # (if value is a map)
          def [](k)
            target.parameter_names.include?(k) ? target.send(k) : target.options[k]
          end

          ##
          # Check if the key is present in the hash
          def include?(k)
            target.parameter_names.include?(k) || target.options.include?(k)
          end

          def initialize(target)
            @target = target
          end
        end

        instance_scope do
          ##
          # Lazy initializer
          def dependencies
            if @dependencies.nil?
              @dependencies = Set.new
              depends_on(parameter_names.map { |name| send(name) })
            end

            @dependencies
          end

          ##
          # Parameter names list
          #
          # Instance-level alias for list_all_parameter_names
          def parameter_names
            self.class.list_all_parameter_names
          end

          ##
          # Validate all parameters
          #
          # Performs calculation of all specified parameters to check options validity
          def validate
            parameter_names.each { |name| send(name) }
          end

          ##
          # Evaluate all parameters
          #
          # Return parameters as a hash
          def parameters_map
            parameter_names.each_with_object({}) { |name, obj| obj[name] = send(name) }
          end

          ##
          # Transforms parametrized into an instance of recursive concept
          def to_recursive
            RecursiveAdapter.new(self)
          end

          attr_reader :getter
        end

        ##
        # Class-level mixins
        #
        # It's a DSL extension to declaratively define parameters.
        class_scope do
          ##
          # List all defined parameter names
          #
          # The list includes both the class parameters and all ancestor
          # parameters.
          def list_all_parameter_names
            ancestors
              .select { |mod| mod.include?(Parametrized) }
              .inject(Set.new) do |parameter_collection, mod|
                parameter_collection.merge(mod.parameters.keys)
              end
          end

          ##
          # Parameters defined in the class
          #
          # Returns map from parameter name to parameter object of the parameters
          # defined only in the class.
          def parameters
            @parameters ||= {}
          end

          ##
          # Get parameter object by name
          #
          # Look-up by the parameter object name recursively through class
          # inheritance hierarchy.
          # * +parameter_alias+ - parameter name
          def get_parameter(parameter_alias)
            ancestor =
              ancestors
              .select { |mod| mod.include?(Parametrized) }
              .find { |mod| mod.parameters.key?(parameter_alias) }

            ancestor.parameters[parameter_alias] if ancestor
          end

          ##
          # Class-level parameter declaration method
          #
          # Being a part of parameter declaration DSL, it constructs
          # parameter object, stores it in parameters class level registry
          # and creates a reader method for it. It will throw exception
          # if the parameter name is already occupied by a method or a parameter
          # with the name already exists in the class or any ancestor
          # * +parameter_alias+ - parameter name
          # * +specification+ - parameter specification hash
          def parameter(name, spec = {})
            raise_already_exists(name) if method_defined?(name)

            parameter_object = Parameter.new(name, self, spec)
            parameters[name] = parameter_object
            define_method(name) { guarded_get(self, parameter_object) }
          end

          def raise_already_exists(name)
            parameter_object = get_parameter(name)

            raise(ParameterAlreadyExist.new(parameter_object)) if parameter_object

            raise ParameterMethodNameConflict.new(instance_method(name))
          end
        end
      end
    end
  end
end
