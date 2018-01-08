require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsBoolean do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :as_boolean_field, transform: as_boolean
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/as_boolean_field.*transform.*to boolean/m)
  end
end
