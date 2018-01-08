require 'spec_helper'
require 'aws/templates/utils'

module DummyRender
  extend Aws::Templates::Render

  define_view(Aws::Templates::Artifact) do
    def to_rendered
      instance.options.to_hash.to_a
    end
  end
end

describe Aws::Templates::Runner do
  let(:parameters) do
    {
      '--render=' => 'DummyRender',
      '--artifact=' => 'Aws::Templates::Artifact'
    }
  end

  let(:argv) do
    parameters.map { |k, v| "#{k}#{v}" }
  end

  let(:io) { '' }

  let(:runner) do
    described_class.with(argv, io)
  end

  context 'when label and root options are specified through CLI parameter' do
    before do
      parameters['--options='] = { label: 1, root: 2 }.to_json
    end

    it 'returns empty output' do
      expect(runner.run!).to be == [[:label, 1], [:root, 2]]
    end
  end

  context 'when label and root options are specified through STDIN' do
    let(:io) { { label: 1, root: 2 }.to_json }

    it 'returns empty output' do
      expect(runner.run!).to be == [[:label, 1], [:root, 2]]
    end
  end
end
