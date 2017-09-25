require 'aws/templates/utils/contextualized/filters'
require 'aws/templates/utils/contextualized/proc'
require 'aws/templates/utils/contextualized/hash'
require 'aws/templates/utils/contextualized/nil'
require 'aws/templates/utils/inheritable'

module Aws
  module Templates
    module Utils
      ##
      # Contextualized mixin.
      #
      # It implements class instance-based definitions of context filters.
      # Filters are options hash alterations and transformations
      # which are defined per-class basis and combined according to class
      # hierarchy when invoked. The target mixing entity should be either
      # Module or Class. In the former case it's possible to model set of
      # object which have common traits organized as an arbitrary graph
      # with many-to-many relationship.
      #
      # Important difference from defaults is that the final result returned
      # by "filter" mixed method is a functor. No operations are performed
      # on options.
      module Contextualized
        include Inheritable

        instance_scope do
          ##
          # Context functor
          #
          # It's a mixin method returning resulting context filter functor with all
          # contexts appropriatelly processed. The algorithm is to walk down
          # the hierarchy of the class and aggregate all context filters from its
          # ancestors prioritizing the ones defined earlier in the class hierarchy.
          # The method is working correctly with both parent classes and all
          # Contextualized mixins used in between.
          def context
            @context ||= filter(:scoped, self.class.context, self)
          end

          ##
          # Enclose block into local context
          #
          # You can apply additional filters for the block and make it
          # the context of the block so only code in this closure will
          # have defined filter alterations.
          def contextualize(arg, &blk)
            if blk
              clone._set_context(context.scoped_filter & arg).instance_exec(&blk)
            else
              filter(:scoped, context.scoped_filter & arg, self)
            end
          end

          protected

          def _set_context(new_context)
            @context = filter(:scoped, new_context, self)
            self
          end
        end

        ##
        # Class-level mixins
        #
        # It's a DSL extension to declaratively define context filters
        class_scope do
          ##
          # Context filter assigned to the module
          #
          # Class-level accessor of a filter to be a part of context.
          # The method returns only the filter for the current class
          # without consideration of the class hierarchy.
          def module_context
            @module_context ||= filter(:identity)
          end

          ##
          # Module's context filter
          #
          # Class-level accessor of a filter to be a part of context.
          # The method returns aggregate filter include module's own filters
          # concatenated with all ancestor's filters.
          def context
            @context ||= _contextualized_ancestors.inject(filter(:identity)) do |acc, mod|
              acc & mod.module_context
            end
          end

          def _contextualized_ancestors
            ancestors
              .select { |mod| (mod != Contextualized) && mod.ancestors.include?(Contextualized) }
              .reverse
          end

          ##
          # Add context filter
          #
          # The class method is used to build hierarchical context
          # filtering pipeline using language-provided features such as
          # class inheritance and introspection. You can
          # specify either a lamda, a hash or a filter functor.
          #
          # If no parameters are passed at all, ArgumentError will be thrown.
          def contextualize(fltr)
            raise ArgumentError.new('Proc should be specified') unless fltr
            @module_context = module_context & fltr
          end
        end
      end
    end
  end
end
