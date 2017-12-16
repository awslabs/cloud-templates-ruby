require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # Catalog's organizational unit
    class Unit < Aws::Templates::Composite
      include Artifacts::Catalogized

      default label: proc { name },
              dn: proc { "ou=#{name},#{unit.dn}" }

      parameter :unit,
                description: 'Hierarchical parent of the unit',
                constraint: not_nil,
                transform: as_object(Artifacts::Catalogized)
      parameter :name, description: 'Organizational unit name', constraint: not_nil

      contextualize filter(:add, :shell, :organization) & filter(:override) { { unit: self } }
    end
  end
end
