require 'spec_helper'

describe Aws::Templates::Utils::Parametrized::Concept do
  let(:concept) do
    described_class.from do
      {
        transform: as_string,
        constraint: not_nil
      }
    end
  end

  it 'processes value correctly' do
    expect(concept.process_value(self, 1)).to be == '1'
  end

  it 'fails on nil' do
    expect { concept.process_value(self, nil) }.to raise_error
  end

  context 'with chained concepts' do
    let(:chained) do
      concept & described_class.from do
        { constraint: satisfies('len > 1') { |v| v.length > 1 } }
      end
    end

    it 'has correct chain type' do
      expect(chained).to be_a(Aws::Templates::Utils::Parametrized::Concept::Chain)
    end

    it 'processes value correctly' do
      expect(chained.process_value(self, 12)).to be == '12'
    end

    it 'fails on constraint' do
      expect { chained.process_value(self, 1) }.to raise_error
    end
  end
end
