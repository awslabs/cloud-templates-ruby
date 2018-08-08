require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          class LateBound < self
            protected

            def get(parameter, instance)
              Utils::LateBound.build_from(Utils::LateBound.as_method(parameter.name, instance))
            end
          end
        end
      end
    end
  end
end
