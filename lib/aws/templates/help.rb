require 'aws/templates/utils'

module Aws
  module Templates
    ##
    # Abstract help generator
    #
    # Implements basic functionality which is needed for programmatic help generation.
    # Namely:
    # * Module/entity class lookup
    # * Final formatting
    module Help
      include Templates::Processor

      ##
      # Generate help for the entity
      def process(entity, params = nil)
        ancestors_list = entity.is_a?(::Module) ? entity.ancestors : entity.class.ancestors
        ancestor = ancestors_list.find { |mod| handler?(mod) }
        return unless ancestor

        handler_for(ancestor).new(entity, params).provide
      end

      ##
      # Generate help structure and format it
      #
      # It returns ready-to-be-displayed blob in specific format. Essentially, it processes entity
      # and then formats the output of the processing.
      def show(entity, params = nil)
        format(process(entity, params), params)
      end

      ##
      # Formatting routine
      #
      # Part of inversion-of-control. Must be overriden by a concrete implementation.
      def format(_result, _params = nil)
        raise Templates::Exception::NotImplementedError.new('The method should be overriden')
      end
    end
  end
end
