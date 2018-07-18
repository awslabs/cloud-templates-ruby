require 'spec_helper'
require 'aws/templates/artifact'

using Aws::Templates::Utils::Dependency::Refinements

describe Aws::Templates::Utils::Inspectable do
  let(:artifact) { Aws::Templates::Artifact.new(label: 1, root: 0) }

  describe 'artifact' do
    it 'converts to string correctly' do
      expect(artifact.to_s).to be == 'Aws::Templates::Artifact(0/1)'
    end

    it 'inspects correctly' do
      expect(artifact.inspect).to be == 'Aws::Templates::Artifact(0/1)' \
        '{parameters: {label: 1,parent: nil}, dependencies: Set[]}'
    end
  end

  describe 'dependency' do
    let(:dependency) { artifact.as_a_self_dependency }

    it 'converts to string correctly' do
      expect(dependency.to_s).to be == 'Aws::Templates::Artifact(0/1)'
    end

    it 'inspects correctly' do
      expect(dependency.inspect).to be == 'Dependency(Aws::Templates::Artifact(0/1)' \
        '{parameters: {...}, dependencies: Set[]} => Set[Aws::Templates::Artifact(0/1)])'
    end
  end

  describe 'nested' do
    let(:nested_class) do
      Aws::Templates::Utils::Parametrized::Nested.create_class.with do
        parameter :a
      end
    end

    let(:nested) do
      nested_class.new(artifact, a: 1)
    end

    it 'converts to string correctly' do
      expect(nested.to_s).to be == '<Nested object definition>(in: Aws::Templates::Artifact(0/1))'
    end

    it 'inspects correctly' do
      expect(nested.inspect).to be == '<Nested object definition>' \
        '(in: Aws::Templates::Artifact(0/1)){parameters: {a: 1}, dependencies: Set[]}'
    end
  end
end
