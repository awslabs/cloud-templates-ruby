require 'spec_helper'

describe Aws::Templates::Utils::Expressions::Dsl do
  let(:dsl) do
    described_class.new(
      Aws::Templates::Utils::Expressions::Definition.new do
        cast(::Float, &:to_i)

        var x: Aws::Templates::Utils::Expressions::Variables::Arithmetic
        func(PrettyFunction)

        macro :inc do |x|
          x + 1
        end
      end
    )
  end

  context 'when correct specification is provided' do
    context 'with variable and function' do
      let(:expression) do
        dsl.expression { x + pretty(inc(1)) }
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
          dsl.definition,
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(dsl.definition, :x),
          PrettyFunction.new(dsl.definition, 2)
        )
      end

      it 'composes expression without exceptions' do
        expect { expression }.not_to raise_error
      end

      it 'composes correct expression' do
        expect(expression).to be_eql expected
      end
    end

    context 'with variable and number' do
      let(:expression) do
        dsl.expression { inc(x) + 1 }
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
          dsl.definition,
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
            dsl.definition,
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(dsl.definition, :x),
            1
          ),
          1
        )
      end

      it 'composes expression without exceptions' do
        expect { expression }.not_to raise_error
      end

      it 'composes correct expression' do
        expect(expression).to be_eql expected
      end
    end
  end
end
