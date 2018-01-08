require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsRendered do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :rendered_field, transform: as_rendered(Aws::Templates::Render::Utils::Inspect)
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/rendered_field.*render with Aws::Templates::Render::Utils::Inspect/m)
  end
end
