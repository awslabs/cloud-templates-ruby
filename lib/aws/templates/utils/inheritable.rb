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
          DEFAULT_MODULE = Module.new.freeze

          ##
          # To add class methods also while including the module
          def included(base)
            super(base)
            base.extend(Inheritable::ClassMethods)
            base._merge_class_scope(class_scope || DEFAULT_MODULE)
          end

          def instance_scope(&blk)
            module_eval(&blk)
          end

          def class_scope(&blk)
            if blk
              @class_scope.module_eval(&blk)
              extend @class_scope
            end

            @class_scope
          end

          def _merge_class_scope(mod)
            if @class_scope.nil?
              @class_scope = mod.dup
            else
              @class_scope.include(mod)
            end

            extend @class_scope
          end
        end

        extend ClassMethods
      end
    end
  end
end
