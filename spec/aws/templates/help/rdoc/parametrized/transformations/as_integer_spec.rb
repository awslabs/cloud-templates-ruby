require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsInteger do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :integer_field, transform: as_integer
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc::Processor.process(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/integer_field.*to integer/m)
  end
end
