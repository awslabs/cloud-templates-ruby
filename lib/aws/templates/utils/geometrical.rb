require 'aws/templates/utils/default'
require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/constraints'
require 'aws/templates/utils/parametrized/transformations'

module Aws
  module Templates
    module Utils
      module Geometrical
        include Default
        include Parametrized

        default proc { geometry.nil? ? settings : multiply(geometry, settings) }

        parameter :settings,
                  description: 'Full settings of the artifact',
                  constraint: not_nil,
                  transform: as_hash

        parameter :geometry, description: 'Geometry matrix', transform: as_hash

        def multiply(geometry, settings)
          return unless geometry
          return settings if geometry == true
          matrix = Hash[geometry]
          Hash[
            matrix.lazy
                  .select { |key, sub_geometry| sub_geometry }
                  .map { |key, sub_geometry| [key, multiply(sub_geometry, settings[key])] }
                  .to_a
          ]
        end
      end
    end
  end
end
