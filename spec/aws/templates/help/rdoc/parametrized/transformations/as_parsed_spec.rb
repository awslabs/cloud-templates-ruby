require 'spec_helper'
require 'aws/templates/utils'
require 'polyglot'
require 'treetop'
require 'test_grammar'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsParsed do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :parsed_field, transform: as_parsed(TestGrammarParser)
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/parsed_field.*parse with TestGrammarParser/m)
  end
end
