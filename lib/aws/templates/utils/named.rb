require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/constraints'

module Aws
  module Templates
    module Utils
      ##
      # Named parametrized object mixin
      #
      # Provides a simple utility to define artifacts/objects which have
      # "name" parameter which should be present as :name in the input hash
      module AsNamed
        include Parametrized

        parameter :name, description: 'Name of the object', constraint: not_nil
      end
    end
  end
end
