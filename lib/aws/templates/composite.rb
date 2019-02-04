require 'aws/templates/utils'

module Aws
  module Templates
    ##
    # Composite
    #
    # Composite is an artifact which contain other artifacts and provide
    # DSL syntax sugar to define it
    #
    # A composite can represent complex entities as CloudFormation
    # stacks which can contain settings and infrastructure artifacts inside it.
    # However, it's still a single entity which may be versioned as a
    # whole and can represent the current state of deployed application.
    #
    # Composite is still an artifact and has all methods inherited so
    # besides grouping different artifacts alltogether you can process
    # input parameters too.
    #
    # Composite is a recursive structure as a result of being an artifact
    # so you can construct arbitrary deep hierarchies of objects. Also it
    # supports inheritance as artifact does. So every component defined in
    # the parent class will be initialized properly in all children too.
    class Composite < Artifact
      include Templates::Utils::Contextualized
      using Templates::Utils::Contextualized::Refinements
      using Templates::Utils::Dependency::Refinements

      # propagate root to the components and set itself as the parent
      contextualize filter(:add, :root) & (filter(:override) { { parent: self } })

      ##
      # Dictionary of artifacts and their labels the composite is
      # consisting of
      #
      # Accessor returning dictionary of artifacts currently residing in
      # composite instance with labels as keys
      attr_reader :artifacts

      ##
      # Shortcut for accessing artifacts by their labels
      #
      # The method returns either stored artifact object or throws a
      # descriptive exception.
      def [](artifact_label)
        unless artifacts.key?(artifact_label)
          raise "There is no artifact #{artifact_label}" \
            " in composite #{label}"
        end

        artifacts[artifact_label].as_a_dependency.to_self
      end

      def []=(artifact_label, artifact_object)
        if artifacts.key?(artifact_label)
          if artifacts[artifact_label] != artifact_object.object
            raise "Artifact #{artifact_label} is already present " \
              "in composite #{label}"
          end
        else
          artifacts[artifact_label] = artifact_object.object
        end

        artifact_object.as_a_dependency.to_self
      end

      ##
      # Artifacts definition block for DSL
      #
      # An element of the framework DSL. Allows you to define
      # composite's artifacts declaratively with using standard language
      # features.
      def self.components(*args, &blk)
        return self if blk.nil?

        define_method(:create_components) do
          super()
          instance_exec(*args, &blk)
        end

        self
      end

      ##
      # Add components into the composite's instance
      #
      # Analog of class-level "components" method to add components after
      # artifact creation when using class-level definitions are not
      # appropriate
      def components(&blk)
        instance_exec(&blk)
        self
      end

      ##
      # Syntax sugar to create composite classes on spot
      #
      # Create a new child class of the current class and executes a
      # block in the context of the class object optionally passing a list
      # of arguments to it.
      def self.for(*args, &blk)
        klass = Class.new(self)
        klass.instance_eval(*args, &blk) unless blk.nil?
        klass
      end

      ##
      # Artifact definition constructor in DSL
      #
      # Defines a single artifact in composite's definition block. This
      # method was designed to be used inside of composite block but you
      # can use it elsewhere else applied on a class instance.
      #
      # * +type+ - artifact type (class)
      # * +params+ - optional map of artifact options
      # * +blk+ - a block which will be passed to artifacts constructor;
      #           applications may vary but particular one is adding
      #           artifacts into composite during instantiation
      def artifact(type, params = nil, &blk)
        artifact_object = create_artifact_object(type, params, &blk)
        self[artifact_object.label] = artifact_object
        artifact_object.as_a_dependency.to_self
      end

      ##
      # Put labels on the artifact
      #
      # Put the artifact into the artifact storage under arbitrary aliases.
      #
      # * +artifact_object+ - artifact object to put
      # * +labels+ - labels to assign to the artifact
      def label_as(artifact_object, *labels)
        labels.flatten.each do |artifact_label|
          self[artifact_label] = artifact_object
        end

        artifact_object
      end

      ##
      # Provisions parameters and initializes nested artifacts
      def initialize(*params, &blk)
        super(*params)
        @artifacts = Templates::Utils::ArtifactStorage.new
        create_components
        instance_exec(&blk) if blk
      end

      ##
      # Find artifacts by criteria
      #
      # The method allows flexible introspection of the artifacts
      # enclosed into the composite's storage. The method is just a proxy
      # for the storage method with the same name
      #
      # * +search_params+ - map of search parameters:
      # ** +recursive+ - if true, search will be performed recusrsively
      #                  in nested composites
      # ** +label+ - search for artifacts which have the label
      # ** +parameters+ - search for artifacts which have specified
      #                   parameters values; it's a multi-level map so
      #                   you can check for nested values also
      def search(search_params = {})
        artifacts.search(search_params)
      end

      protected

      def create_components; end

      def create_artifact_object(type, params = nil, &blk)
        type.new(options.filter(&contextualize(params.to_filter)), &blk)
      end
    end
  end
end
