require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Parametrized wrapper
        #
        # Wraps hash or object into "parametrized" instance. Used for nested parameter definitions.
        class Nested
          using Utils::Recursive
          using Utils::Dependency::Refinements

          include Parametrized
          include Utils::Default
          include Utils::Dependent

          attr_reader :options

          def self.getter
            Parametrized::Getter::AsIs.instance
          end

          def self.create_class(scope)
            klass = ::Class.new(self)
            klass.singleton_class.send(:define_method, :scope) { scope }
            klass
          end

          def self.with(mod)
            include mod
            self
          end

          def self.inspect
            to_s
          end

          def self.scope
            ::Object
          end

          def self.to_s
            "<Nested object definition in #{scope}>"
          end

          def dependency?
            true
          end

          def root
            parent.root
          end

          attr_reader :parent

          def dependencies
            @dependencies ||= ::Set.new
          end

          protected

          def initialize(parent, obj)
            @parent = parent
            depends_on(obj) if obj.dependency?
            @options = Utils::Options.new(defaults, obj.to_recursive)
          end
        end
      end
    end
  end
end
