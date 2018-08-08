require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        class Builder
          module Routing
            extend Utils::Routing

            register Utils::Parametrized::Transformation::AsObject,
                     LateBound::Values::Structure
            register Utils::Parametrized::Transformation::AsHash,
                     LateBound::Values::Containers::Map
            register Utils::Parametrized::Transformation::AsList,
                     LateBound::Values::Containers::List
            register Utils::Parametrized::Transformation,
                     LateBound::Values::Scalar
            register ::NilClass, LateBound::Values::Value
          end
        end
      end
    end
  end
end
