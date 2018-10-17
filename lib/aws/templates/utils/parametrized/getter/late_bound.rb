require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Creates late-bound value for the parameter
          #
          # Other way around - makes parent parameter a late bound value
          class LateBound < self
            attr_reader :meta

            def initialize(meta = nil)
              @meta = meta
            end

            protected

            def get(parameter, instance)
              Utils::LateBound.build_from(
                Utils::LateBound.as_method(
                  parameter.name,
                  instance,
                  instance,
                  meta
                )
              )
            end
          end
        end
      end
    end
  end
end
