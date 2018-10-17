require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        class Builder
          ##
          # Transformation-Late Bound class mapping
          #
          # Different transformations can produce late bound values of different sub-classes.
          # It's required to correctly emulate behaviour of late-bound data structures and types.
          # For instance map and list should support index operator. However, the value allowed
          # in the index operator will be different for map and index.
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
