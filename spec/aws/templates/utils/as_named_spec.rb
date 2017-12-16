require 'spec_helper'

describe Aws::Templates::Utils::AsNamed do
  let(:named_class) do
    Class.new do
      include Aws::Templates::Utils::Parametrized

      include Aws::Templates::Utils::AsNamed

      attr_reader :options

      def self.getter
        as_is
      end

      def initialize(hsh)
        @options = hsh
      end
    end
  end

  it 'returns name' do
    expect(named_class.new(name: 'orugva').name).to be == 'orugva'
  end

  it 'fails when name is not provided' do
    expect { named_class.new({}).name }.to raise_error(/Name of the object/)
  end
end
