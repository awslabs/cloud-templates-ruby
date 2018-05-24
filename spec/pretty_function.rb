require 'spec_helper'

class PrettyFunction < Aws::Templates::Utils::Expressions::Function
  include Aws::Templates::Utils::Expressions::Features::Arithmetic

  name_as :pretty

  parameter :c,
            description: 'Just regular parameter',
            transform: as_string,
            constraint: not_nil
end
