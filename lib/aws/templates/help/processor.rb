require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      ##
      # Abstract help generator
      #
      # Implements basic functionality which is needed for programmatic help generation.
      # Namely:
      # * Module/entity class lookup
      # * Final formatting
      class Processor < Templates::Processing::Processor
        ##
        # Empty provider
        #
        # Singleton provider which returns nil as processed result
        class EmptyProvider < Templates::Processing::Handler
          extend Templates::Utils::Singleton
          def to_processed; end
        end

        protected

        def handler_class_for(entity)
          ancestors_list = entity.is_a?(::Module) ? entity.ancestors : entity.class.ancestors
          ancestor = ancestors_list.find { |mod| self.class.handler?(mod) }
          ancestor.nil? ? EmptyProvider : self.class.handler_for(ancestor)
        end
      end
    end
  end
end
