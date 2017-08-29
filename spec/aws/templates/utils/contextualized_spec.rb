require 'spec_helper'
require 'aws/templates/utils/contextualized'
require 'aws/templates/utils/options'

describe Aws::Templates::Utils::Contextualized do
  let(:including_class) do
    Class.new do
      include Aws::Templates::Utils::Contextualized

      contextualize ->(opts, _) { opts.dup }
    end
  end

  let(:including_module) do
    Module.new do
      include Aws::Templates::Utils::Contextualized

      contextualize lambda { |_, memo|
        memo.delete(:z)
        memo
      }
    end
  end

  describe 'module include' do
    it 'has filter DSL method' do
      expect(including_module).to respond_to(:contextualize)
    end
  end

  describe 'class include' do
    it 'has parameter DSL method' do
      expect(including_class).to respond_to(:contextualize)
    end
  end

  context 'Class is inherited and the module is included' do
    let(:parametrized_class) do
      klass = Class.new(including_class)
      klass.send(:include, including_module)
      klass
    end

    let(:instance) { parametrized_class.new }

    let(:options) { Aws::Templates::Utils::Options.new(a: 5, z: 10) }

    it 'returns properly filtered options' do
      expect(options.filter(&instance.context).to_hash).to be == { a: 5 }
    end
  end

  context 'Class is inherited and extended with filters' do
    let(:parametrized_class) do
      Class.new(including_class) do
        contextualize lambda { |_, memo|
          memo.delete(:r)
          memo
        }

        contextualize lambda { |_, memo|
          memo[:x] = memo[:a] + 1
          memo
        }
      end
    end

    let(:options) { Aws::Templates::Utils::Options.new(a: 3, r: 5, z: 7) }

    describe 'DSL' do
      it 'has filter DSL method' do
        expect(parametrized_class).to respond_to(:contextualize)
      end
    end

    context 'Instance of the class created' do
      let(:instance) { parametrized_class.new }

      it 'filters it according to specified parameters' do
        expect(options.filter(&instance.context).to_hash).to be == { a: 3, z: 7, x: 4 }
      end
    end

    context 'Class is inherited and a filter added' do
      let(:extending_class) do
        Class.new(parametrized_class) do
          contextualize lambda { |_, memo|
            memo[:w] = memo[:z] + memo[:x]
            memo
          }
        end
      end

      let(:instance) { extending_class.new }

      it 'filters it according to specified parameters' do
        expect(options.filter(&instance.context).to_hash).to be == { a: 3, z: 7, x: 4, w: 11 }
      end

      context 'Class inherited and a filtered mixin added' do
        let(:mixing_class) do
          k = Class.new(extending_class)
          k.send(:include, including_module)
          k
        end

        let(:instance) { mixing_class.new }

        it 'filters it according to specified parameters' do
          expect(options.filter(&instance.context).to_hash).to be == { a: 3, x: 4, w: 11 }
        end
      end
    end
  end
end
