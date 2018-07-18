require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Common functionality for documenting inheritable properties.
        #
        # Examples of inheritable properties:
        # * parameters
        # * context filters
        # Those have one thing in common: they are inherited from a parent class to any child and
        # to generate full documentation you need to go over all of them respecting class/module
        # hierarchy. The class implements utility methods and provides IoC stubs to define
        # specific behaviors with ease.
        class Inheritable < Rdoc::Provider
          def self.header(header = nil)
            return @header if header.nil?
            @header = header
          end

          def to_processed
            desc = ancestors_description
            sub(text(self.class.header.gsub(/(\S+)/, '_\1_')), desc) if desc
          end

          protected

          def description_for(_mod)
            raise Templates::Exception::NotImplementedError.new('The method should be overriden')
          end

          private

          def ancestors_description
            descriptions = context.ancestors_with(self.class.entity)
                                  .map { |mod| description_for(mod) }
                                  .reject(&:nil?)
                                  .to_a

            list(:BULLET, *descriptions) unless descriptions.empty?
          end
        end
      end
    end
  end
end
