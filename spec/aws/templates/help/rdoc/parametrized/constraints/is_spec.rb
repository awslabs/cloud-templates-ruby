require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Constraints::Is do
  let(:parametrized) do
    Module.new { include Aws::Templates::Utils::Parametrized }
  end

  let(:help) { Aws::Templates::Help::Rdoc::Processor.process(parametrized) }

  context 'with class and attributes' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :is_an_instance_with_attribute, constraint: is?(::String => enum('a', 'b'))
      end
    end

    it 'prints documentation' do
      expect(help).to match(
        /is_an_instance_with_attribute.*should be an instance of:.*String.*one of: "a","b"/m
      )
    end
  end

  context 'with class' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :is_an_instance, constraint: is?(::Enumerable)
      end
    end

    it 'prints documentation' do
      expect(help).to match(
        /is_an_instance.*should be an instance of:.*Enumerable/m
      )
    end
  end
end
