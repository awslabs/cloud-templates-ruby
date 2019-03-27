require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        class Definition
          ##
          # Definition registry abstract class
          #
          # Storage applicable for various definitions in expression DSL. Specific quirks for
          # different types of DSL entities are implemented in sub-classes
          class Registry
            attr_reader :store
            attr_reader :parent

            alias to_h store

            def initialize(parent, source = nil)
              @parent = parent
              @store = {}

              source.nil? ? use_defaults : extend!(source)
            end

            def invoke(_element, *_)
              raise 'Must be overriden'
            end

            def register!(element, definition)
              raise "Invalid definition #{definition}" unless correct_definition?(definition)
              raise "Invalid element #{element}" unless correct_element?(element)

              store[element] = definition
              self
            end

            def extend(source)
              self.class.new(parent, self).extend!(source)
            end

            def extend!(source)
              return self if source.nil?

              raise "#{source} can't be transformed to hash" unless source.respond_to?(:to_h)

              source.to_h.each_pair { |element, definition| register!(element, definition) }

              self
            end

            def present?(element)
              store.key?(element)
            end

            def lookup(element)
              raise "#{element} is not registered" unless present?(element)

              store[element]
            end

            protected

            def correct_definition?(_definition)
              raise 'Must be overriden'
            end

            def correct_element?(_element)
              raise 'Must be overriden'
            end

            def use_defaults; end
          end
        end
      end
    end
  end
end
