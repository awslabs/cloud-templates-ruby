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
          # Empty class scope
          #
          # Identity class scope which contains nothing. Used as base case for class scope
          # inheritance hierarchy.
          module ClassScope
          end

          ##
          # To add class methods also while including the module
          def included(base)
            super(base)
            base.extend(ClassMethods)
            base.extend(ClassScope)
          end

          def instance_scope(&blk)
            module_eval(&blk)
          end

          def class_scope(&blk)
            raise ScriptError.new('class_scope should have a block') if blk.nil?
            _define_class_scope unless _class_scope_defined?
            ClassScope.module_eval(&blk)
            extend ClassScope
          end

          def _class_scope_defined?
            @class_scope_defined || false
          end

          def _define_class_scope
            const_set(:ClassScope, ClassScope.dup)
            @class_scope_defined = true
          end
        end

        extend ClassMethods
      end
    end
  end
end
