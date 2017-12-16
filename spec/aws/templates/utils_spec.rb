require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Utils do
  describe 'lookup_module' do
    let(:test_module) do
      described_class.lookup_module('TestEmpty::Stuff::Here::Test')
    end

    it 'finds the test module' do
      expect { test_module }.not_to raise_error
    end

    it 'finds the correct test module' do
      expect(test_module).respond_to?(:test)
    end
  end
end
