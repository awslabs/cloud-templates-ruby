require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsModule do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :module_field, transform: as_module
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc::Processor.process(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/module_field.*as a module/m)
  end
end
