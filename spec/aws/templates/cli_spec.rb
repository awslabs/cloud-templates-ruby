require 'spec_helper'
require 'aws/templates/utils'

class DummyRender < Aws::Templates::Rendering::Render
  define_view(Aws::Templates::Artifact) do
    def to_processed
      instance.options.to_hash.to_a
    end
  end
end

class StubShell < ::Thor::Shell::Basic
  def initialize(output, error)
    @output = output
    @error = error
    super()
  end

  protected

  def stdout
    @output || STDOUT
  end

  def stderr
    @error || STDERR
  end
end

describe Aws::Templates::Cli do
  let(:parameters) {}

  let(:command) {}

  let(:arguments) {}

  let(:argv) { [command].concat(arguments).concat(parameters.map { |k, v| "#{k}#{v}" }) }

  let(:stdout) { StringIO.new('', 'w+') }

  let(:stderr) { StringIO.new('', 'w+') }

  let(:shell) { StubShell.new(stdout, stderr) }

  describe 'render' do
    let(:parameters) do
      {
        '--render=' => 'DummyRender',
        '--options=' => { label: 1, root: 2 }.to_json
      }
    end

    let(:command) { 'render' }

    let(:arguments) { ['Aws::Templates::Artifact'] }

    before do
      described_class.start(argv, shell: shell)
    end

    it 'prints rendered output' do
      expect(stdout.string).to be == "[[\"label\",1],[\"root\",2]]\n"
    end
  end

  describe 'document' do
    let(:parameters) { {} }

    let(:command) { 'document' }

    let(:arguments) { ['Aws::Templates::Artifact'] }

    before do
      described_class.start(argv, shell: shell)
    end

    it 'prints documentation' do
      expect(stdout.string).to match(/Artifact.*Parents.*Parameters/m)
    end
  end
end
