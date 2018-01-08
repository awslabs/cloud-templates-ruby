require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Constraints::SatisfiesCondition do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :satisfies_field, constraint: satisfies('less than 10') { |v| v < 10 }
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/satisfies_field.*less than 10/m)
  end
end
