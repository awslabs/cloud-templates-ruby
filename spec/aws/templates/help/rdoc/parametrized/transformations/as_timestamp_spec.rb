require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Transformations::AsTimestamp do
  let(:parametrized) do
    Module.new do
      include Aws::Templates::Utils::Parametrized
      parameter :as_timestamp_field, transform: as_timestamp
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc::Processor.process(parametrized) }

  it 'prints documentation' do
    expect(help).to match(/as_timestamp_field.*transform.*to timestamp/m)
  end
end
