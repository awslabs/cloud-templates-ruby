require 'spec_helper'

describe Aws::Templates::Utils::Expressions::Parser do
  let(:definition) do
    Aws::Templates::Utils::Expressions::Definition.new do
      cast(::Float) { |v| Aws::Templates::Utils::Expressions::Number.new(self, v.to_i) }

      var x: Aws::Templates::Utils::Expressions::Variables::Arithmetic

      func(f: Aws::Templates::Utils::Expressions::Features::Arithmetic) { parameter :a }
      func(fg: Aws::Templates::Utils::Expressions::Features::Arithmetic) do
        parameter :a
        parameter :b
      end
      func(gh: Aws::Templates::Utils::Expressions::Features::Arithmetic) { parameter :a }

      macro :inc do |x|
        x + 1
      end
    end
  end

  let(:dsl) do
    Aws::Templates::Utils::Expressions::Dsl.new(definition)
  end

  let(:parser) do
    described_class.with(definition)
  end

  let(:expression) do
    parser.parse('(x + f([inc(1), 2.7, "3", 4])) * fg(45, 34) + gh(45) + 67.8')
  end

  it 'parses without exception' do
    expect { expression }.not_to raise_error
  end

  it 'parses the text into a correct representation' do
    expect(expression).to be_eql(
      dsl.expression { (x + f([2, 2.7, '3', 4])) * fg(45, 34) + gh(45) + 67 }
    )
  end
end
