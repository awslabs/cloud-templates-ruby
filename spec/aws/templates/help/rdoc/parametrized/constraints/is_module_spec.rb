require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Constraints::IsModule do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :module_field, constraint: module?
      parameter :restricted_module_field, constraint: module?(::Numeric)
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  it 'prints documentation for module_field' do
    expect(help).to match(/module_field.*should be a module/m)
  end

  it 'prints documentation for restricted_module_field' do
    expect(help).to match(/restricted_module_field.*should be Numeric/m)
  end
end
