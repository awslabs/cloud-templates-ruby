require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsList do
  let(:parametrized) {}

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  context 'with any element' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :simple_list_field, transform: as_list
      end
    end

    it 'prints documentation' do
      expect(help).to match(/simple_list_field.*can be anything/m)
    end
  end

  context 'with typed element' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :typed_list_field,
                  transform: as_list(
                    name: :thing,
                    description: 'One of many',
                    constraint: not_nil
                  )
      end
    end

    it 'prints documentation' do
      expect(help).to match(/typed_list_field.*thing.*One of many.*be nil/m)
    end
  end
end
