require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsObject do
  let(:parametrized) {}

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  context 'without specification' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :object_field, transform: as_object
      end
    end

    it 'prints documentation' do
      expect(help).to match(/object_field.*as an object\s*$/m)
    end
  end

  context 'with object scheme' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :nested_object_field,
                  transform: as_object {
                    default id: 1
                    parameter :id, description: 'Tux', constraint: not_nil
                  }
      end
    end

    it 'prints documentation' do
      expect(help).to match(/nested_object_field.*as an object.*id.*Tux.*id.*1/m)
    end
  end
end
