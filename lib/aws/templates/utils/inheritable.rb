require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Introduces class method inheritance through module hierarchy
      module Inheritable
        ##
        # Core class-level mixins
        #
        # Contains core logic of the inheritance feature. This module is used as extention
        # in every including module/class to expose appropriate module-level primitives for
        # handling inheritance of class-scope methods.
        module ClassMethods
          ##
          # To add class methods also while including the module
          def included(base)
            super(base)
            base.extend(ClassMethods)
            base.class_scope(_class_scope)
            when_inherited(base)
          end

          def inherited(subclass)
            when_inherited(subclass)
          end

          def instance_scope(&blk)
            module_eval(&blk)
          end

          def class_scope(mod = nil, &blk)
            _class_scope.module_eval(&blk) if blk
            _class_scope.send(:include, mod) if mod
            extend _class_scope
          end

          def _class_scope_duplicated?
            @class_scope_duplicated || false
          end

          def _class_scope
            return @_class_scope if @_class_scope

            @_class_scope = ::Module.new
          end

          def when_inherited(_base); end
        end

        extend ClassMethods
      end
    end
  end
end
