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

          attr_reader :options

          def self.getter
            as_is
          end

          def self.create_class
            ::Class.new(self)
          end

          def self.with(mod)
            include mod
            self
          end

          def self.inspect
            to_s
          end

          def self.to_s
            '<Nested object definition>'
          end

          def dependency?
            true
          end

          def root
            parent.root
          end

          attr_reader :parent

          def links
            @links ||= ::Set.new
          end

          protected

          def initialize(parent, obj)
            @parent = parent
            @links = obj.links if obj.dependency?
            @options = Utils::Options.new(defaults, obj.to_recursive)
          end
        end
      end
    end
  end
end
