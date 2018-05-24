require 'spec_helper'

describe Aws::Templates::Utils::Expressions::Definition do
  let(:definition) do
    described_class.new do
      variables x: Aws::Templates::Utils::Expressions::Variables::Arithmetic

      function(:b) { parameter :a }
      function(PrettyFunction)
      function(c: PrettyFunction) { parameter :z }
    end
  end

  let(:expected_definitions) do
    {
      x: Aws::Templates::Utils::Expressions::Variables::Arithmetic,
      b: definition.definitions[:b],
      pretty: PrettyFunction,
      c: definition
    }
  end

  it 'succeds when specifiaction is provided' do
    expect { definition }.not_to raise_error
  end

  describe 'expected definitions' do
    it 'contains variable x' do
      expect(definition.definitions[:x])
        .to be == Aws::Templates::Utils::Expressions::Variables::Arithmetic
    end

    describe 'function b' do
      let(:function) do
        definition.definitions[:b]
      end

      it 'is a simple function' do
        expect(function).to be < Aws::Templates::Utils::Expressions::Function
      end

      it 'contains parameter a' do
        expect(function.get_parameter(:a)).to be_a Aws::Templates::Utils::Parametrized::Parameter
      end
    end

    describe 'pretty function' do
      let(:function) do
        definition.definitions[:pretty]
      end

      it 'is the PrettyFunction' do
        expect(function).to be == PrettyFunction
      end

      it 'contains parameter c' do
        expect(function.get_parameter(:c)).to be_a Aws::Templates::Utils::Parametrized::Parameter
      end
    end

    describe 'function c' do
      let(:function) do
        definition.definitions[:c]
      end

      it 'is the PrettyFunction' do
        expect(function).to be < PrettyFunction
      end

      it 'contains parameter c' do
        expect(function.get_parameter(:z)).to be_a Aws::Templates::Utils::Parametrized::Parameter
      end
    end
  end
end
