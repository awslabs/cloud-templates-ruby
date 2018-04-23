require 'aws/templates/utils'
require 'facets/string/pathize'
require 'facets/module/lastname'

module Aws
  module Templates
    module Utils
      module Dsl
        ##
        # DSL element class mixin
        #
        # DSL elements are instantiable classes for different definitions in target DSL. For
        # instance, NotNil constraint class is a DSL element which is represented by not_nil
        # factory method.
        module Element
          include Utils::Inheritable
          include Utils::Scoped

          instance_scope do
            def to_s
              "#{self.class.dsl_name}#{arguments}"
            end

            def arguments; end
          end

          class_scope do
            def as_dsl(str)
              define_singleton_method(:dsl_name) { str }
            end

            def dsl_name
              @dsl_name ||= lastname.pathize
            end

            def create(*args, &blk)
              new(*args, &blk)
            end

            def create_scoped(scope, *args, &blk)
              element = create(*args, &blk)
              element.scope = scope
              element
            end

            def create_at_location(location, scope, *args, &blk)
              element = create_scoped(scope, *args, &blk)
              element.location = location
              element
            end
          end
        end
      end
    end
  end
end
