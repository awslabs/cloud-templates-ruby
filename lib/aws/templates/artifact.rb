require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/getters'
require 'aws/templates/utils/parametrized/constraints'
require 'aws/templates/utils/default'
require 'aws/templates/utils/options'
require 'aws/templates/utils/dependent'

module Aws
  module Templates
    ##
    # Basic artifact
    #
    # "Artifact" in the terminology of the framework is an entity which
    # can represent any parametrizable object type from any problem domain
    # possible. For instance, for CloudFormation, artifacts are resources
    # in a CFN template, the template itself
    #
    # If your target domain is infrastructure orchestration, artifact is
    # usually a single entity such as S3 volume, ASG, DynamoDB table, etc.
    # However, the notion of artifact is not particularly fixed since the
    # framework can be used for different purposes including documents
    # generation and general templating tasks. Basically, artifact is a
    # single parametrizable entity or a step in input hash
    # transformations.
    #
    # Artifact classes work together with meta-programming mechanisms in
    # Ruby language enabling artifacts inheritance in the natural way
    # using simple Ruby classes. The feature is useful when you have a
    # group of artifacts which share the same basic parameters but differ
    # in details.
    #
    # The central part in the framework is played by processed hash. All
    # mechanisms are based on simple ad-hoc merging rules which are
    # described at merge method but basis can be described as following:
    # each superclass initializer accepts children class processed hash
    # as input hash and the hash is processed recursively through
    # class hierarchy. Old values are newer removed by default so the
    # whole process is no more than continuous hash expansion.
    #
    #    class Piece < Artifact
    #      default { { output: options[:param] } }
    #    end
    #
    #    class ConcretePiece < Piece
    #      default param: 'Came from child'
    #    end
    #
    #    Piece.new(a: 1, b: 2).options.to_hash # => { a: 1, b: 2, output: nil }
    #    ConcretePiece.new(a: 1, b: 2).options.to_hash
    #    # => { a: 1, b: 2, output: 'Came from child', param: 'Came from child' }
    #
    # Also, as one of the peculiarities of the framework, you can override
    # any auto-generated parameter with input hash if they have the same
    # name/path.
    class Artifact
      include Utils::Default
      include Utils::Parametrized
      include Utils::Dependent

      attr_accessor :options

      def self.getter
        as_is
      end

      def self.to_s
        return super unless name.nil?
        "<Subclass of (#{superclass}) with features #{features}>"
      end

      def self.features
        @features ||= ancestors.take_while { |mod| mod != superclass }
      end

      # Create new child class with mixins
      #
      # The class method is useful when you want to mix-in some behavior adjustments
      # without creating a new named class. For instance when you want to mix-in
      # some defaults into class and instantiate a few instances out of that.
      def self.featuring(*modules)
        return self if modules.empty?

        modules.inject(Class.new(self)) do |klass, mod|
          klass.send(:include, mod)
        end
      end

      ##
      # Artifact's label
      #
      # All artifacts have labels assigned to them to simplify reverse
      # look-up while linking dependencies. Interpretation of this field is purely
      # application-specific.
      default label: proc { object_id }

      parameter :label, description: 'Artifact\'s label', constraint: not_nil

      ##
      # Meta field
      #
      # The field is used to attach arbitrary information to artifacts which is not directly
      # relevant to artifact properties. This attribute can be used for tagginng, for instance.
      def meta
        return @meta if @meta

        meta_option = options[:meta]
        @meta = meta_option.nil? ? {} : meta_option.to_hash
      end

      ##
      # Artifact's root
      #
      # A root is an object which bundles artifacts into common rendering group helping to find
      # disconnected pieces of dependency graph. If two artifacts have different roots they
      # definitelly belong to different graphs.
      def root
        options[:root]
      end

      default root: proc { object_id }

      # Artifact's look-up path through all ancestors
      def lookup_path
        acc = [label]
        ancestor = parent

        until ancestor.nil?
          acc << ancestor.label
          ancestor = ancestor.parent
        end

        acc << root
        acc.reverse!
      end

      ##
      # Artifact's parent
      #
      # Artifacts can be organized into a hierarchy of composition. This field points back to the
      # artifact's parent.
      parameter :parent, description: 'Artifact parent'

      ##
      # Create a new artifact
      #
      # Artifact constructor. If you want to override it you might probably
      # want to look into default first. All default values specified in the
      # class definition and all its ancestors are processed and merged with
      # options so it contains fully-processed hash.
      #
      # The algorithm of the processing is the following:
      # * merge defaults hash with passed options; options take precedence
      # * merge the hash with default calculations return results; calculations output
      #   takes preference
      # * pass resulting hash to superclass initializer
      # * merge resulting hash with options; options take preference
      #
      # * +params+ - input parameters hash to be used during following
      #              hash transformations and expansions.
      def initialize(params)
        @options = Utils::Options.new(defaults, params)
      end
    end
  end
end
