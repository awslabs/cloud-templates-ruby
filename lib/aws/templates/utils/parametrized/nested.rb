require 'set'
require 'aws/templates/utils/default'
require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/getters'
require 'aws/templates/utils/dependent'
require 'aws/templates/utils/options'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Parametrized wrapper
        #
        # Wraps hash or object into "parametrized" instance. Used for nested parameter definitions.
        class Nested
          include Parametrized
          include Default
          include Dependent

          attr_reader :options

          def self.getter
            as_is
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
            @dependencies ||= Set.new
          end

          protected

          def initialize(parent, obj)
            unless obj.respond_to?(:to_recursive)
              raise "Value #{obj} can't be transformed " \
                    'into a recursive container'
            end

            @parent = parent
            depends_on(obj) if obj.dependency?
            @options = Options.new(defaults, obj.to_recursive)
          end
        end
      end
    end
  end
end
