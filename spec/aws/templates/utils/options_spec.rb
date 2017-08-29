require 'spec_helper'
require 'aws/templates/utils/options'

describe Aws::Templates::Utils::Options do
  let(:options) do
    described_class.new(
      a: 1,
      b: { c: 2 },
      d: { c: { z: 3 } },
      :* => { c: { :* => 5 } }
    )
  end

  describe 'merge' do
    let(:merged_options) do
      options.merge(a: 12, b: { w: 30 }, d: { c: { z: 34 } })
    end

    let(:result) do
      {
        a: 12,
        b: { c: 2, w: 30 },
        d: { c: { z: 34 } },
        :* => { c: { :* => 5 } }
      }
    end

    it 'has correct class' do
      expect(merged_options).to be_a_kind_of(described_class)
    end

    it 'merges according to the algorithm' do
      expect(merged_options.to_hash).to be == result
    end
  end

  describe 'lookup' do
    it 'returns value when simple path is specified' do
      expect(options[:b, :c]).to be == 2
    end

    it 'return nil when value is not found' do
      expect(options[:b, :d, :z]).to be_nil
    end

    it 'wildcard lookup works' do
      expect(options[:q, :c, :e]).to be == 5
    end
  end

  describe 'assignment' do
    it 'existing path assignment works' do
      options[:b, :c] = 3
      expect(options[:b, :c]).to be == 3
    end

    it 'new path assignment works' do
      options[:b, :z, :y, :d] = 10
      expect(options[:b, :z, :y, :d]).to be == 10
    end

    it 'throws an exception when value is not hash' do
      options[:b, :c, :y, :d] = 13
      expect(options[:b, :c, :y, :d]).to be == 13
    end
  end
end
