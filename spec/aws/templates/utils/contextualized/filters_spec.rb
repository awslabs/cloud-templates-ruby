require 'spec_helper'
require 'aws/templates/utils/contextualized'
require 'aws/templates/utils/options'

describe Aws::Templates::Utils::Contextualized::Filter do
  let(:filtered_class) do
    Class.new do
      include Aws::Templates::Utils::Contextualized
    end
  end

  let(:test_class) {}

  let(:instance) { test_class.new }

  describe 'override' do
    let(:test_class) do
      Class.new(filtered_class) do
        contextualize a: 'awesome'
      end
    end

    it 'adds element into hash' do
      opts = Aws::Templates::Utils::Options.new(b: 2, c: 3)
      expect(opts.filter(&instance.context).to_hash).to be == { a: 'awesome' }
    end

    context 'when full context copied' do
      let(:test_class) do
        Class.new(filtered_class) do
          contextualize filter(:copy) & { a: 'awesome' }
        end
      end

      it 'overrides element in the hash' do
        opts = Aws::Templates::Utils::Options.new(a: 1, b: 2, c: 3)
        expect(opts.filter(&instance.context).to_hash).to be == { a: 'awesome', b: 2, c: 3 }
      end
    end
  end

  describe 'remove' do
    let(:test_class) do
      Class.new(filtered_class) do
        contextualize filter(:copy) & filter(:remove, :a, r: [:x])
      end
    end

    it 'does nothing to hash without elements to remove' do
      opts = Aws::Templates::Utils::Options.new(b: 2, c: 3)
      expect(opts.filter(&instance.context).to_hash).to be == { b: 2, c: 3 }
    end

    it 'removes specified key from hash' do
      opts = Aws::Templates::Utils::Options.new(a: 1, b: 2, c: 3, r: { x: 1, z: 0 })
      expect(opts.filter(&instance.context).to_hash).to be == { b: 2, c: 3, r: { z: 0 } }
    end
  end

  describe 'add' do
    let(:test_class) do
      Class.new(filtered_class) do
        contextualize filter(:add, :a, r: [:x])
      end
    end

    it 'adds the only key found' do
      opts = Aws::Templates::Utils::Options.new(a: 1, b: 2, c: 3)
      expect(opts.filter(&instance.context).to_hash).to be == { a: 1 }
    end

    it 'adds specified keys from hash' do
      opts = Aws::Templates::Utils::Options.new(a: 1, b: 2, c: 3, r: { x: 1, z: 0 })
      expect(opts.filter(&instance.context).to_hash).to be == { a: 1, r: { x: 1 } }
    end
  end

  describe 'chain' do
    let(:test_class) do
      Class.new(filtered_class) do
        contextualize filter(:copy) & filter(:remove, :a) & filter(:override, f: 10)
      end
    end

    it 'does nothing to hash without elements to remove' do
      opts = Aws::Templates::Utils::Options.new(b: 2, c: 3)
      expect(opts.filter(&instance.context).to_hash).to be == { b: 2, c: 3, f: 10 }
    end

    it 'removes specified key from hash' do
      opts = Aws::Templates::Utils::Options.new(a: 1, b: 2, c: 3)
      expect(opts.filter(&instance.context).to_hash).to be == { b: 2, c: 3, f: 10 }
    end
  end

  describe 'identity' do
    let(:test_class) do
      Class.new(filtered_class) do
        contextualize filter(:copy) & filter(:identity)
      end
    end

    it 'adds element into hash' do
      opts = Aws::Templates::Utils::Options.new(b: 2, c: 3)
      expect(opts.filter(&instance.context).to_hash).to be == { b: 2, c: 3 }
    end
  end
end
