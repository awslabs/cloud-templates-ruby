require 'spec_helper'

describe Aws::Templates::Utils::Expressions::Definition do
  let(:definition) do
    described_class.new do
      cast(::Float, &:to_i)

      var x: Aws::Templates::Utils::Expressions::Variables::Arithmetic

      func(:b) { parameter :a }
      func(PrettyFunction)
      func(c: PrettyFunction) { parameter :z }

      macro :two do |x|
        x + 2
      end
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
      expect(definition.identifiers.lookup(:x).definition)
        .to be == Aws::Templates::Utils::Expressions::Variables::Arithmetic
    end

    describe 'function b' do
      let(:function) do
        definition.identifiers.lookup(:b).definition
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
        definition.identifiers.lookup(:pretty).definition
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
        definition.identifiers.lookup(:c).definition
      end

      it 'is the PrettyFunction' do
        expect(function).to be < PrettyFunction
      end

      it 'contains parameter c' do
        expect(function.get_parameter(:z)).to be_a Aws::Templates::Utils::Parametrized::Parameter
      end
    end

    describe 'macro two' do
      let(:macro) do
        definition.identifiers.lookup(:two).definition
      end

      it 'is the PrettyFunction' do
        expect(macro).to be_a Proc
      end

      it 'contains parameter c' do
        expect(macro.arity).to be == 1
      end
    end

    describe 'float cast' do
      let(:cast) do
        definition.casts.lookup(::Float)
      end

      it 'is the PrettyFunction' do
        expect(cast).to be_a Proc
      end
    end
  end
end
