require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Constraints::AllOf do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :all_of_field, constraint: all_of(not_nil, enum(:a, :b, :c))
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc::Processor.process(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/all_of_field.*be nil.*one of.*a..b..c/m)
  end
end
