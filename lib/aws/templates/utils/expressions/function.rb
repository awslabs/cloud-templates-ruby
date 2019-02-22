require 'aws/templates/utils'
require 'facets/string/pathize'
require 'facets/module/lastname'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Function DSL class
        #
        # Embodies properties specific to functions like name and string formatting into the usual
        # written form.
        class Function < BasicFunction
          def self.name_as(str)
            @function_name = str.to_sym
          end

          def self.function_name
            return @function_name if @function_name
            return if lastname.nil? || self == Function

            @function_name ||= lastname.pathize
          end

          def to_s
            "#{self.class.function_name}(#{parameters_map.values.map(&:to_s).join(',')})"
          end

          def self.with(name, feature = nil, &blk)
            k = feature.is_a?(::Class) ? Class.new(feature) : Class.new(self).featuring(feature)
            k.name_as(name)
            k.class_eval(&blk) if block_given?
            k
          end

          def self.featuring(feature)
            include feature if feature
            self
          end

          def self.instantiate(name, *args)
            raise 'You can\'t instantiate anonymous function' if function_name.nil?
            raise "#{name} is not #{function_name}" if name != function_name

            new(*args)
          end
        end
      end
    end
  end
end
