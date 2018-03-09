require 'spec_helper'
require 'aws/templates/artifact'

module TestTest
  module A; end
  module B; end
end

describe Aws::Templates::Artifact do
  let(:artifact_class) do
    Class.new(Aws::Templates::Artifact) do
      default a: 'b',
              b: proc { options[:c].upcase }

      parameter :c
      parameter :d
    end
  end

  let(:dependency) do
    Struct.new(:"dependency?", :links)
  end

  let(:just_object) do
    Struct.new(:root)
  end

  context 'when featuring class is created' do
    let(:featuring_class) { artifact_class.featuring(TestTest::A, TestTest::B) }

    it 'returns correct class name' do
      expect(featuring_class.to_s).to match(/Subclass.*TestTest..B.*TestTest..A/)
    end
  end

  context 'when instance created' do
    let(:params) do
      {
        c: 'qwe',
        d: {
          e: {
            f: { a: dependency.new(true, [just_object.new(2)]) },
            g: { d: dependency.new(true, [just_object.new(1)]) }
          }
        }
      }
    end

    let(:instance) { artifact_class.new(params) }

    context 'without label' do
      it 'contains auto-generated label' do
        expect(instance.label).not_to be_nil
      end
    end

    context 'without root' do
      it 'root is not empty' do
        expect(instance.root).not_to be_nil
      end
      it 'doesn\'t have any dependencies' do
        expect(instance.dependencies).to be_empty
      end
    end
    context 'with label' do
      before { params[:label] = 'b' }
      it 'contains passed label' do
        expect(instance.label).to be == 'b'
      end
    end
    context 'with root' do
      before { params[:root] = 1 }
      it 'contains one dependency' do
        expect(instance.dependencies).to be == [just_object.new(1)].to_set
      end
      it 'contains passed root' do
        expect(instance.root).to be == 1
      end
    end
    context 'with different root' do
      before { params[:root] = 2 }
      it 'contains one dependency' do
        expect(instance.dependencies).to be == [just_object.new(2)].to_set
      end
    end
    context 'without overrides' do
      before { params.merge!(root: 3, label: 'thing') }

      let(:expected) do
        {
          label: 'thing',
          a: 'b',
          b: 'QWE',
          c: 'qwe',
          d: {
            e: {
              f: { a: dependency.new(true, [just_object.new(2)]) },
              g: { d: dependency.new(true, [just_object.new(1)]) }
            }
          },
          root: 3
        }
      end

      it 'calculates with defaults' do
        expect(instance.options.to_hash).to be == expected
      end
    end
    context 'with override' do
      before { params.merge!(root: 3, label: 'thing', a: 'rty') }

      let(:expected) do
        {
          label: 'thing',
          a: 'rty',
          b: 'QWE',
          c: 'qwe',
          d: {
            e: {
              f: { a: dependency.new(true, [just_object.new(2)]) },
              g: { d: dependency.new(true, [just_object.new(1)]) }
            }
          },
          root: 3
        }
      end

      it 'calculates with defaults' do
        expect(instance.options.to_hash).to be == expected
      end
    end
  end

  context 'when instance of child class created' do
    let(:child_class) do
      Class.new(artifact_class) do
        default a: deleted,
                c: proc { options[:d].tr(' ', '.') }
      end
    end

    let(:params) { { root: 3, label: 'thing', d: 'q w e' } }

    let(:child_instance) { child_class.new(params) }

    let(:expected) do
      {
        root: 3,
        label: 'thing',
        b: 'Q.W.E',
        c: 'q.w.e',
        d: 'q w e'
      }
    end

    it 'overlays overrides' do
      expect(child_instance.options.to_hash).to be == expected
    end
  end
end
