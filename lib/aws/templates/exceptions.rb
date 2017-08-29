module Aws
  module Templates
    ##
    # Parameter definition exception
    #
    # Meta-programming exception related to Parametrized DSL
    class ParametrizedDSLError < StandardError
    end

    ##
    # Parameter already exists
    #
    # If you're trying to define a parameter in a parametrized artifact
    # and this parameter either already defined for the class or defined
    # in an ancestor.
    class ParameterAlreadyExist < ParametrizedDSLError
      # Parameter object of the conflicting parameter
      attr_reader :parameter

      def initialize(target_parameter)
        @parameter = target_parameter
        super(
          "Parameter #{target_parameter.name} already in " \
          "#{target_parameter.klass}."
        )
      end
    end

    ##
    # Invalid parameter specification hash
    #
    # If unknown option is passed in a parameter description block
    class ParameterSpecificationIsInvalid < ParametrizedDSLError
      # Parameter object faulty options were specified for
      attr_reader :parameter

      # Options unknown to Parametrized
      attr_reader :options

      def initialize(target_parameter, opts)
        @parameter = target_parameter
        @options = opts

        super(
          'Unsupported options are in specification for ' \
          "parameter #{target_parameter.name} in class " \
          "#{target_parameter.klass} : #{opts}"
        )
      end
    end

    ##
    # A regular method and a parameter have the same name in a class
    #
    # A parameter was specified with the same name as exsiting method
    # in the class or in an ancestor of the class.
    class ParameterMethodNameConflict < ParametrizedDSLError
      # Method object of the method specified
      attr_reader :method_object

      def initialize(target_method)
        @method_object = target_method

        super(
          "Parameter name #{target_method.name} clashes with a method name in " \
          "#{target_method.owner.name}"
        )
      end
    end

    ##
    # View was not found for the object
    #
    # View map was checked and there is no appropriate view class
    # for the object class found in the registry.
    class ViewNotFound < RuntimeError
      # Instance of the object class render lookup was performed for
      attr_reader :instance

      def message
        "Can't find any view for #{instance} of class #{instance.class}"
      end

      def initialize(target_instance)
        super()
        @instance = target_instance
      end
    end

    ##
    # Parameter exception
    #
    # Happens during runtime if an error happens during parameter
    # evaluation
    class ParameterException < RuntimeError
      # Parameter object
      attr_reader :parameter

      def message
        cause.nil? ? super : "#{super} : #{cause.message}"
      end

      def initialize(target_parameter, custom_message)
        @parameter = target_parameter
        super(custom_message)
      end
    end

    ##
    # If something happens during parameter calculation
    class NestedParameterException < ParameterException
      def initialize(target_parameter)
        super(
          target_parameter,
          'Exception was thrown by nested parameter while calculating ' \
            "#{target_parameter.name} (#{target_parameter.description})"
        )
      end
    end

    ##
    # A value failed constraints
    class ParameterValueInvalid < ParameterException
      attr_reader :value
      attr_reader :object

      def initialize(target_parameter, target_object, target_value)
        @value = target_value
        @object = target_object
        super(
          target_parameter,
          message_text(target_parameter, target_object, target_value)
        )
      end

      private

      def message_text(target_parameter, target_object, target_value)
        message = "Value '(#{target_value.inspect})' violates constraints specified for " \
          "#{target_parameter.name} (#{target_parameter.description}) in " \
          "#{target_parameter.klass}"

        unless target_object.class == target_parameter.klass
          message += " and inherited by #{target_object.class}"
        end

        message
      end
    end

    ##
    # Getter is not specified
    #
    # Getter wasn't specified neither for the individual parameter nor for the mixing instance nor
    # for its class.
    class ParameterGetterIsNotDefined < ParameterException
      def initialize(target_parameter)
        super(
          target_parameter,
          "Can't find getter for #{target_parameter.name} (#{target_parameter.description}): " \
            'a getter should be attached either to the parameter or the instance ' \
            'or the instance class'
        )
      end
    end

    ##
    # Options exception
    #
    # The parent of all exceptions Options method can throw
    class OptionError < ArgumentError
    end

    ##
    # Recursive value is expected
    #
    # Value passed doesn't not support "recursive" contract. See Utils.recursive?
    class OptionShouldBeRecursive < OptionError
      attr_reader :value

      def initialize(value)
        @value = value
        super("Value #{value} is not a recursive data structure")
      end
    end

    ##
    # Deleted branch detected
    #
    # While traversing Options layers for a value, deleted branch marker was discovered.
    class OptionValueDeleted < OptionError
      attr_reader :path

      def initialize(path)
        @path = path
        super(
          "Deleted value was detected while traversing path. The path left untraversed: #{path}"
        )
      end
    end

    ##
    # Scalar is met while traversing Options path
    #
    # Path is not empty yet but we can't traverse deeper because the current value is a scalar
    class OptionScalarOnTheWay < OptionError
      attr_reader :value
      attr_reader :path

      def initialize(value, path)
        @value = value
        @path = path

        super(
          "Value #{value} is not a recursive data structure and we have still #{path} keys " \
            'to look-up'
        )
      end
    end
  end
end
