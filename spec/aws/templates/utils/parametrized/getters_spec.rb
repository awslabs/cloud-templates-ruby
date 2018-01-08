require 'spec_helper'
require 'aws/templates/utils/parametrized'

module Getters
  include Aws::Templates::Utils::Parametrized
end

describe Aws::Templates::Utils::Parametrized::Getter do
  let(:parametrized_class) do
    Class.new do
      include Aws::Templates::Utils::Parametrized

      attr_reader :options

      def initialize(options)
        @options = options
      end
    end
  end

  let(:options_hash) {}

  let(:getter) {}

  let(:test_class) do
    k = Class.new(parametrized_class)
    k.parameter(:something, getter: getter)
    k
  end

  let(:instance) { test_class.new(options_hash) }

  describe 'as_instance_variable' do
    let(:parametrized_class) do
      Class.new do
        include Aws::Templates::Utils::Parametrized

        def initialize(something)
          @something = something
        end
      end
    end

    let(:options_hash) { 'a' }

    let(:getter) { Getters.as_instance_variable }

    it 'returns the value from hash by parameter name' do
      expect(instance.something).to be == 'a'
    end
  end

  describe 'as_is' do
    let(:options_hash) { { something: 'a' } }

    let(:getter) { Getters.as_is }

    it 'returns the value from hash by parameter name' do
      expect(instance.something).to be == 'a'
    end
  end

  describe 'path' do
    let(:options_hash) do
      hash = { object: { something: 'a' } }

      class << hash
        def [](*path)
          if path.size == 1
            super(path[0])
          else
            path.inject(self) { |acc, elem| acc[elem] }
          end
        end
      end

      hash
    end

    context 'with static path' do
      let(:getter) { Getters.path(:object, :something) }

      it 'returns value correctly' do
        expect(instance.something).to be == 'a'
      end
    end

    context 'with dynamic path' do
      let(:getter) { Getters.path { %i[object something] } }

      it 'returns value correctly' do
        expect(instance.something).to be == 'a'
      end
    end
  end

  describe 'value' do
    let(:options_hash) { { something: 3 } }

    context 'with static value' do
      let(:getter) { Getters.value(1) }

      it 'returns value correctly' do
        expect(instance.something).to be == 1
      end
    end

    context 'with dynamic calculation' do
      let(:getter) { Getters.value { options[:something] + 2 } }

      it 'returns value correctly' do
        expect(instance.something).to be == 5
      end
    end
  end

  describe 'one_of' do
    let(:getter) do
      Getters.one_of(->(p) { options[p.name] }, ->(_) { options[:default] })
    end

    context 'with first option value' do
      let(:options_hash) { { something: 'a' } }

      it 'returns the value' do
        expect(instance.something).to be == 'a'
      end
    end

    context 'with another options value' do
      let(:options_hash) { { default: 'a' } }

      it 'returns the value' do
        expect(instance.something).to be == 'a'
      end
    end
  end
end
