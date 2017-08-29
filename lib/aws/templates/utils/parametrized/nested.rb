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
            !dependencies.empty?
          end

          def dependencies
            @dependencies ||= Set.new
          end

          protected

          def initialize(obj)
            depends_on(obj) if obj.dependency?
            @options = Options.new(obj)
            process_options(obj)
          end
        end
      end
    end
  end
end
