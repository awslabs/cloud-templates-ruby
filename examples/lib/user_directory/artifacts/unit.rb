require 'aws/templates/composite'
require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/constraints'
require 'user_directory/artifacts/user'
require 'user_directory/artifacts/catalogized'

module UserDirectory
  ##
  # Catalog's organizational unit
  class Unit < Aws::Templates::Composite
    include Catalogized

    default label: -> { name },
            dn: -> { "ou=#{name},#{unit.dn}" }

    parameter :unit,
              description: 'Hierarchical parent of the unit',
              constraint: not_nil,
              transform: as_object(Catalogized)
    parameter :name, description: 'Organizational unit name', constraint: not_nil

    contextualize filter(:add, :shell, :organization) & filter(:override) { { unit: self } }
  end
end
