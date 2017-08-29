require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/constraints'

module UserDirectory
  ##
  # Parameter mixin containing universal parameters for indexed objects
  module IDed
    include Aws::Templates::Utils::Parametrized
    parameter :id, description: 'Object ID', constraint: not_nil
  end
end
