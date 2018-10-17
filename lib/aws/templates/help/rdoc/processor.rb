require 'aws/templates/utils'
require 'rdoc'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Rdoc-based help generator
        #
        # The generator uses RDoc utility classes internally to compose documentation blurbs.
        # It supports all output formats as RDoc.
        class Processor < Help::Processor
          extend Templates::Utils::Singleton

          include Rdoc::Texting

          routing Rdoc::Routing

          ##
          # Compose a doc fragment for scalar value
          #
          # Abstract documentation provider for scalar values.
          class Scalar < Rdoc::Provider
            def to_processed
              sub(parameters.nil? ? text(value) : text("_#{parameters}_ #{value}"))
            end

            protected

            def value
              raise 'Should be overriden'
            end
          end

          ##
          # Compose a doc fragment for lambda
          class Calculable < Scalar
            for_entity ::Proc

            protected

            def value
              location = context.source_location

              message = begin
                          "Calculated in #{context.binding.receiver}"
                        rescue ArgumentError
                          'Calculated'
                        end

              location.nil? ? message : "#{message} (#{location.join(':')})"
            end
          end

          ##
          # Default help provider
          #
          # Does a few preliminary check and either use insection of the target object or, if it
          # supports recursive concept, goes recursively into it and composes resulting list tree
          # of descriptions.
          class DefaultProvider < Rdoc::Provider
            for_entity ::Object

            def to_processed
              return _recursive if Utils.recursive?(context)

              _inspection
            end

            private

            def _inspection
              return '*deleted*' if context == Templates::Utils::Default.deleted

              str = context.inspect
              sub(parameters.nil? ? text(str) : text("_#{parameters}_ #{str}"))
            end

            def _recursive
              container = context
                          .keys
                          .each_with_object(list) { |key, l| l << processed_for(context[key], key) }

              parameters.nil? ? sub(container) : sub(text("_#{parameters}_"), container)
            end
          end

          protected

          def post_process(result)
            _formatter.start_accepting

            if result
              result = list(:LABEL, result) if result.is_a?(RDoc::Markup::ListItem)
              result.accept(_formatter)
            end

            _formatter.end_accepting
          end

          private

          def _formatter
            return @_formatter if @_formatter

            @_formatter = if options && options.include?(:formatter)
              Templates::Utils.lookup_module(options[:formatter]).new
            else
              RDoc::Markup::ToAnsi.new
            end
          end
        end
      end
    end
  end
end
