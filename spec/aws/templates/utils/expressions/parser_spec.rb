require 'spec_helper'

describe Aws::Templates::Utils::Expressions::Parser do
  let(:definition) do
    Aws::Templates::Utils::Expressions::Definition.new do
      variables x: Aws::Templates::Utils::Expressions::Variables::Arithmetic

      function(f: Aws::Templates::Utils::Expressions::Features::Arithmetic) { parameter :a }
      function(fg: Aws::Templates::Utils::Expressions::Features::Arithmetic) do
        parameter :a
        parameter :b
      end
      function(gh: Aws::Templates::Utils::Expressions::Features::Arithmetic) { parameter :a }
    end
  end

  let(:dsl) do
    Aws::Templates::Utils::Expressions::Dsl.new(definition)
  end

  let(:parser) do
    described_class.with(definition)
  end

  let(:expression) do
    parser.parse('(x + f([1, 2, "3", 4])) * fg(45, 34) + gh(45)')
  end

  it 'parses without exception' do
    expect { expression }.not_to raise_error
  end

  it 'parses the text into a correct representation' do
    expect(expression).to be_eql(
      dsl.expression { (x + f([1, 2, '3', 4])) * fg(45, 34) + gh(45) }
    )
  end
end
