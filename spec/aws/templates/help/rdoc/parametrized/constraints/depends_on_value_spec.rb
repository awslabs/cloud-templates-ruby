require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Constraints::DependsOnValue do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :field
      parameter :depends_on_value_requires_field,
                constraint: depends_on_value(a: requires(:field))
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  it 'prints documentation' do
    expect(help).to match(
      /depends_on_value_requires_field.*depends.*when[^\n]+a.*requires.*field/m
    )
  end
end
