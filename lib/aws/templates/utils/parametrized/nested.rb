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
          # Mixin with extensions to class-level methods
          module Extendable
            def with(obj = nil, &definition)
              mix_in(obj || definition)
            end

            def mix_in(obj)
              return if obj.nil?

              if obj.is_a?(Module)
                include(obj)
              elsif obj.respond_to?(:to_proc)
                class_eval(&obj)
              else
                raise "Invalid module definition #{mod.inspect}"
              end

              self
            end
          end

          using Utils::Recursive

          include Parametrized
          include Utils::Default

          attr_reader :options

          def self.getter
            as_is
          end

          def self.create_class
            ::Class.new(self) { extend Extendable }
          end

          def self.inspect
            to_s
          end

          def self.to_s
            '<Nested object definition>'
          end

          def root
            parent.root
          end

          attr_reader :parent

          protected

          def initialize(parent, obj)
            @parent = parent
            @options = Utils::Options.new(defaults, obj.to_recursive)
          end
        end
      end
    end
  end
end
