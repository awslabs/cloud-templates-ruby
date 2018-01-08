require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsHash do
  let(:parametrized) {}

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  context 'with any key and value' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :as_random_hash, transform: as_hash
      end
    end

    it 'prints documentation' do
      expect(help).to match(/key.*can be anything.*value.*can be anything/m)
    end
  end

  context 'with key specification' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :as_hash_with_defined_key,
                  transform: as_hash {
                    key name: :id,
                        description: 'Object ID',
                        constraint: not_nil
                  }
      end
    end

    it 'prints documentation' do
      expect(help).to match(/id.*Object ID.*be nil.*value.*anything/m)
    end
  end

  context 'with value specification' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :as_hash_with_defined_value,
                  transform: as_hash {
                    value name: :object, description: 'Object itself', constraint: not_nil
                  }
      end
    end

    it 'prints documentation' do
      expect(help).to match(/key.*anything.*object.*Object itself.*be nil/m)
    end
  end

  context 'with key and value specifications' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :as_hash_with_defined_key_and_value,
                  transform: as_hash {
                    key name: :id, description: 'Object ID', constraint: not_nil
                    value name: :object, description: 'Object itself', constraint: not_nil
                  }
      end
    end

    it 'prints documentation' do
      expect(help).to match(/id.*Object ID.*be nil.*object.*Object itself.*be nil/m)
    end
  end
end
