require 'aws/templates/utils'

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
        ##
        # Parameter object
        #
        # The object incorporates parameter specification and basic logic for
        # value extraction, checking and transformation. Parameter objects
        # are created at each parameter description.
        class Parameter
          include Utils::Scoped

          attr_reader :name
          attr_accessor :description
          attr_accessor :concept

          def getter_for(instance = nil)
            return @getter unless @getter.nil?
            return if instance.nil?
            return instance.getter if instance.respond_to?(:getter)
            return instance.class.getter if instance.class.respond_to?(:getter)
          end

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
          # ** +:concept+ - instead of specifying transformation and constraint individually you
          #                 can specify a concept; both are not mutually exclusive and you can
          #                 chain additional transformation or constraint to a concept
          def initialize(name, specification = {})
            @name = name
            set_specification(specification)
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
            instance.instance_exec(value, &concept)
          rescue Templates::Exception::ParameterRuntimeException
            raise Templates::Exception::ParameterProcessingException.new(instance, self)
          end

          private

          def extract_value(instance)
            obj = getter_for(instance)
            raise Templates::Exception::ParameterGetterIsNotDefined.new(instance, self) if obj.nil?

            if obj.respond_to?(:to_hash)
              obj
            elsif obj.respond_to?(:to_proc)
              execute_getter(instance, obj)
            else
              obj
            end
          end

          def execute_getter(instance, getter)
            instance.instance_exec(self, &getter)
          rescue Templates::Exception::ParameterRuntimeException
            raise Templates::Exception::ParameterProcessingException.new(instance, self)
          end

          def set_specification(
            description: nil, getter: nil, transform: nil, constraint: nil, concept: nil
          )
            @description = description
            @getter = getter
            @concept = Parametrized::Concept.from(concept) &
                       Parametrized::Concept.from(transform: transform, constraint: constraint)
          end
        end

        ##
        # Makes parametrized accessible as recursive concept
        class RecursiveAdapter
          attr_reader :target

          ##
          # Defined hash keys
          def keys
            target.parameter_names.to_set.merge(target.options.keys)
          end

          ##
          # Index operator
          #
          # Performs intermediate transformation of value if needed (if value is a lambda) and
          # returns it wrapping into Definition instance with the same context if needed
          # (if value is a map)
          def [](key)
            target.parameter?(key) ? target.send(key) : target.options[key]
          end

          ##
          # Check if the key is present in the hash
          def include?(key)
            target.parameter?(key) || target.options.include?(key)
          end

          def deleted?(_key)
            false
          end

          def initialize(target)
            @target = target
          end
        end

        include Utils::Inheritable
        include Utils::Guarded
        include Utils::Inspectable

        ##
        # Class-level mixins
        #
        # It's a DSL extension to declaratively define parameters.
        class_scope do
          def when_inherited(base)
            base.parameters.merge!(parameters)
            children << base
          end

          def children
            @children ||= []
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
            parameters[parameter_alias]
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

            parameter_object = Parameter.new(name, spec)
            parameter_object.location = caller_locations[0..0].first
            accept_parameter(parameter_object)
          end

          def accept_parameter(parameter_object)
            name = parameter_object.name
            raise_already_exists(name) if method_defined?(name)

            parameter_object.scope = self
            parameters[name] = parameter_object
            children.each { |child| child.parameters[name] = parameter_object }

            define_method(name) { _parameter_value_for(name, parameter_object) }

            parameter_object
          end

          def raise_already_exists(name)
            parameter_object = get_parameter(name)

            if parameter_object
              raise(
                Templates::Exception::ParameterAlreadyExist.new(parameter_object)
              )
            end

            raise Aws::Templates::Exception::ParameterMethodNameConflict.new(instance_method(name))
          end

          include Getter::Dsl
          include Transformation::Dsl
          include Constraint::Dsl
        end

        def guarded_get(instance, parameter_object)
          guarded_for(instance, parameter_object) { parameter_object.get(self) }
        end

        ##
        # Lazy initializer
        def dependencies
          if @dependencies.nil?
            @dependencies = ::Set.new
            depends_on(parameters_map.values)
          end

          @dependencies
        end

        ##
        # Parameter names list
        #
        # Instance-level alias for list_all_parameter_names
        def parameter_names
          self.class.parameters.keys
        end

        ##
        # Evaluate all parameters
        #
        # Return parameters as a hash
        def parameters_map
          @parameters_map ||= {}

          return @parameters_map if parameter_names.size == @parameters_map.size

          parameter_names.each_with_object(@parameters_map) do |name, obj|
            next if @parameters_map.key?(name)

            obj[name] = _calculate_parameter_by_name(name)
          end
        end

        ##
        # Validate all parameters
        #
        # Performs calculation of all specified parameters to check options validity
        alias validate parameters_map

        def parameter?(name)
          self.class.parameters.key?(name)
        end

        ##
        # Transforms parametrized into an instance of recursive concept
        def to_recursive
          RecursiveAdapter.new(self)
        end

        private

        def _calculate_parameter_by_name(name)
          _calculate_parameter(self.class.parameters[name])
        end

        def _calculate_parameter(parameter_object)
          guarded_get(self, parameter_object)
        end

        def _parameter_value_for(name, parameter_object)
          @parameters_map ||= {}

          return @parameters_map[name] if @parameters_map.key?(name)

          @parameters_map[name] = _calculate_parameter(parameter_object)
        end

        include Utils::Dependency::Dependent
      end
    end
  end
end
