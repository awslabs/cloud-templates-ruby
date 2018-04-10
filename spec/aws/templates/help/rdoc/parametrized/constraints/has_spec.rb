require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Parametrized::Constraints::Has do
  let(:parametrized) do
    Module.new { include Aws::Templates::Utils::Parametrized }
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(parametrized) }

  context 'with attributes and constraints' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :attributes_with_constraints, constraint: has?(azdc: not_nil)
      end
    end

    it 'prints documentation' do
      expect(help).to match(
        /attributes_with_constraints.*should have the fields:.*azdc.*can\'t be nil/m
      )
    end
  end

  context 'with attributes' do
    let(:parametrized) do
      Module.new do
        include Aws::Templates::Utils::Parametrized
        parameter :attributes, constraint: has?(:azdc)
      end
    end

    it 'prints documentation' do
      expect(help).to match(/attributes.*should have the fields:.*azdc/m)
    end
  end
end
