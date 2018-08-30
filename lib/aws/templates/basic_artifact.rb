require 'aws/templates/utils'

module Aws
  module Templates
    ##
    # Basic artifact class
    #
    # Mostly used to break circular dependencies in code. Contains basic class utils.
    class BasicArtifact
      include Templates::Utils::Dependency::Dependent
      include Templates::Help::Dsl

      attr_accessor :options

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
    end
  end
end
