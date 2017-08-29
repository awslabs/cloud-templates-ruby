require 'aws/templates/composite'
require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/constraints'
require 'user_directory/artifacts/catalogized'

module UserDirectory
  ##
  # Catalog's organization
  class Organization < Aws::Templates::Composite
    include Catalogized

    default dn: -> { "o=#{name}" }
    parameter :name, description: 'Organization name', constraint: not_nil

    contextualize filter(:override) { { organization: self, unit: self } }
  end
end
