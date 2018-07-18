require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Constraints::DependsOnValue do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :field
      parameter :depends_on_value_requires_field,
                constraint: depends_on_value(ardx: requires(:field))
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc::Processor.process(parametrized) }

  it 'prints documentation' do
    expect(help).to match(
      /depends_on_value_requires_field.*depends.*ardx.*requires.*field/m
    )
  end
end
