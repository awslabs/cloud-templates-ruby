require 'aws/templates/utils'
require 'facets/string/modulize'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # DSL for defining scope filters.
          #
          # The mixin adds DSL methods to both class context and instance context.
          module Dsl
            include Utils::Inheritable

            ##
            # Mixin for filter factory method
            #
            # Adds filter factory method to the target
            module FilterFactory
              ##
              # Filter factory method
              #
              # It creates a filter based on type identifier and parameters with optional block
              # which will be passed unchanged to the filter constructor.
              # * +type+ - type identifier; can by either symbol or string
              # * +args+ - filter constructor arguments
              # * +blk+ - optional block to be passed to filter constructor
              def filter(type, *args, &blk)
                Filter.const_get(type.to_s.modulize).new(*args, &blk)
              end
            end

            ##
            # Class-level mixins
            #
            # It's a DSL extension to declaratively define context filters
            class_scope do
              include FilterFactory
            end

            instance_scope do
              include FilterFactory
            end
          end
        end
      end
    end
  end
end
