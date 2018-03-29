require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Dependency
        ##
        # Dependency marker proxy
        #
        # Used internally in the framework to mark an object as potential dependency. There are
        # other alternatives for doing the same like singleton class and reference object.
        # The wrapper is needed when target instance doesn't support singleton classes (Numeric,
        # Symbol, TrueClass, FalseClass, NilClass).
        class Wrapper < Utils::Proxy
          using Dependency::Refinements

          include Utils::Dependency::Depending

          # BasicObject is so basic that this part is missing too
          def class
            Wrapper
          end

          def object
            delegate
          end

          ##
          # Initialize the proxy
          def initialize(source_object)
            @delegate = source_object.object
            links.merge(source_object.links) if source_object.dependency?
          end
        end
      end
    end
  end
end
