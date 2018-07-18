require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      ##
      # Aggregated documentation provider
      #
      # A composite which generates documentation for entities which have a few documentation
      # aspects which must be assembled in the resulting piece. Documentation aspects must have
      # their own documentation providers. Aggregate will assemble them all according to the
      # specified ordering.
      class Aggregate < Provider
        # DSL to declare aspects which should be displayed before entity-specific fragment
        def self.before(*mods)
          before_providers.concat(get_handlers_for(mods))
        end

        # DSL to declare aspects which should be displayed after entity-specific fragment
        def self.after(*mods)
          after_providers.concat(get_handlers_for(mods))
        end

        # The list of aspects to be displayed before entity-specific fragment
        def self.before_providers
          @before_providers ||= superclass < Aggregate ? superclass.before_providers.dup : []
        end

        # The list of aspects to be displayed after entity-specific fragment
        def self.after_providers
          @after_providers ||= superclass < Aggregate ? superclass.after_providers.dup : []
        end

        def to_processed
          fragments = _process_through(self.class.before_providers)
                      .push(fragment)
                      .concat(_process_through(self.class.after_providers))

          fragments.compact!

          compose(fragments) unless fragments.empty?
        end

        # Get list of aspect handlers for the list of classes/modules
        def self.get_handlers_for(mods)
          mods.map { |mod| processor.handler_for(mod) }
        end

        protected

        ##
        # Compose documentation aspects
        #
        # Implements inversion-of-control to provide implementation-specific way of composing
        # documentation fragments
        def compose(_fragments)
          raise Templates::Exception::NotImplementedError.new('The method should be overriden')
        end

        ##
        # Entity-specific fragment
        def fragment
          raise Templates::Exception::NotImplementedError.new('The method should be overriden')
        end

        private

        def _process_through(providers)
          providers.map { |p| p.new(parent, context, parameters).to_processed }
        end
      end
    end
  end
end
