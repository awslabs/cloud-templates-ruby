require 'spec_helper'
require 'aws/templates/composite'

using Aws::Templates::Utils::Dependency::Refinements

class A
  attr_reader :params

  def label
    @params[:label]
  end

  def initialize(p)
    @params = p
  end

  def eql?(other)
    (self.class == other.class) && (params.to_hash == other.params.to_hash)
  end

  def ==(other)
    eql?(other)
  end

  def !=(other)
    !eql?(other)
  end
end

describe Aws::Templates::Composite do
  let(:composite_class) do
    Class.new(Aws::Templates::Composite) do
      default rocket: 'spacehawk'
      default spaceship: 'martyr'

      contextualize filter(:copy) &
                    { erased: 'forever' } &
                    (filter(:override) { { root: self } })

      components do
        artifact A, label: 'b'
        artifact A, label: 'a', w: artifact(A, label: 'z')
        artifact A, label: 'y', w: artifact(A, label: 'x').not_a_dependency
        artifact(
          A,
          filter(:override) { { boomer: options[:rocket].upcase, vehicle: options[:spaceship] } } &
          { label: 'c' }
        )
      end
    end
  end

  let(:parameters) { { label: 'q' } }

  let(:artifacts) do
    instance.artifacts.each_with_object({}) { |(k, v), memo| memo[k] = v.params.to_hash }
  end

  context 'when a parameter is overriden' do
    let(:instance) { composite_class.new(parameters) }

    let(:result) do
      {
        'z' => {
          label: 'z',
          rocket: 'serenity',
          spaceship: 'martyr',
          erased: 'forever',
          root: instance,
          parent: instance
        },
        'x' => {
          label: 'x',
          rocket: 'serenity',
          spaceship: 'martyr',
          erased: 'forever',
          root: instance,
          parent: instance
        },
        'b' => {
          label: 'b',
          rocket: 'serenity',
          spaceship: 'martyr',
          erased: 'forever',
          root: instance,
          parent: instance
        },
        'a' => {
          label: 'a',
          rocket: 'serenity',
          spaceship: 'martyr',
          erased: 'forever',
          w: Aws::Templates::Utils::Dependency.new(
            A.new(
              label: 'z',
              rocket: 'serenity',
              spaceship: 'martyr',
              erased: 'forever',
              root: instance,
              parent: instance
            )
          ),
          root: instance,
          parent: instance
        },
        'y' => {
          label: 'y',
          rocket: 'serenity',
          spaceship: 'martyr',
          erased: 'forever',
          w: A.new(
            label: 'x',
            rocket: 'serenity',
            spaceship: 'martyr',
            erased: 'forever',
            root: instance,
            parent: instance
          ),
          root: instance,
          parent: instance
        },
        'c' => {
          label: 'y',
          rocket: 'serenity',
          spaceship: 'martyr',
          boomer: 'SERENITY',
          vehicle: 'martyr',
          erased: 'forever',
          root: instance,
          parent: instance
        }
      }
    end

    before { parameters[:rocket] = 'serenity' }

    it 'has predictable parameters distribution' do
      v = instance['b'].params.to_hash
      expect(v).to be == result['b']
    end

    it 'throws exception when unknown artifact is being extracted' do
      expect { instance['w'] }.to raise_error RuntimeError, /There is no artifact/
    end

    it 'has all expected artifacts' do
      expect(artifacts['a']).to be == result['a']
    end
  end

  describe 'search' do
    let(:instance) do
      artifact_class = Class.new(Aws::Templates::Artifact) { parameter :yoke }
      nested_class = composite_class
      composite_class.new(parameters).components do
        artifact artifact_class,
                 label: 'w',
                 yoke: Struct.new(:one, :two).new('fruit', 'veggie')
        artifact nested_class, label: 'r'
      end
    end

    describe 'search by label' do
      let(:found_artifacts) { instance.search(label: 'c') }

      it 'is only one artifact labeled c' do
        expect(found_artifacts.size).to be == 1
      end

      it 'finds correct artifact' do
        expect(found_artifacts.first.params[:boomer]).to be == 'SPACEHAWK'
      end
    end

    describe 'search by field' do
      let(:found_artifacts) { instance.search(parameters: { yoke: { two: 'veggie' } }) }

      it 'is only one artifact which has field set' do
        expect(found_artifacts.size).to be == 1
      end

      it 'finds correct artifact' do
        v = found_artifacts.first
        expect(v.yoke.two).to be == 'veggie'
      end
    end

    describe 'search by class' do
      let(:found_artifacts) { instance.search(klass: A) }

      it 'has 3 found artifacts' do
        expect(found_artifacts.size).to be == 6
      end

      it 'finds correct artifacts' do
        expect(found_artifacts.map(&:label).sort).to be == %w[a b c x y z]
      end
    end

    describe 'search recursively' do
      let(:found_artifacts) { instance.search(klass: A, recursive: true) }

      it 'has 6 found artifacts' do
        expect(found_artifacts.size).to be == 12
      end

      it 'finds correct artifacts' do
        expect(found_artifacts.map(&:label).sort).to be == %w[a a b b c c x x y y z z]
      end
    end
  end

  describe 'adding artifacts' do
    shared_examples 'an artifact storage' do
      it 'contains artifact t' do
        expect(instance['t'].params.to_hash).to be == result['t']
      end

      it 'contains expected artifacts' do
        expect(artifacts).to be == result
      end
    end

    before { parameters[:postfix] = 'X' }

    let(:result) do
      {
        'z' => {
          label: 'z',
          rocket: 'spacehawk',
          spaceship: 'martyr',
          erased: 'forever',
          postfix: 'X',
          root: instance,
          parent: instance
        },
        'x' => {
          label: 'x',
          rocket: 'spacehawk',
          spaceship: 'martyr',
          erased: 'forever',
          postfix: 'X',
          root: instance,
          parent: instance
        },
        'b' => {
          label: 'b',
          rocket: 'spacehawk',
          spaceship: 'martyr',
          erased: 'forever',
          postfix: 'X',
          root: instance,
          parent: instance
        },
        'a' => {
          label: 'a',
          rocket: 'spacehawk',
          spaceship: 'martyr',
          erased: 'forever',
          postfix: 'X',
          w: Aws::Templates::Utils::Dependency.new(
            A.new(
              label: 'z',
              rocket: 'spacehawk',
              spaceship: 'martyr',
              erased: 'forever',
              postfix: 'X',
              root: instance,
              parent: instance
            )
          ),
          root: instance,
          parent: instance
        },
        'y' => {
          label: 'y',
          rocket: 'spacehawk',
          spaceship: 'martyr',
          erased: 'forever',
          postfix: 'X',
          w: A.new(
            label: 'x',
            rocket: 'spacehawk',
            spaceship: 'martyr',
            erased: 'forever',
            postfix: 'X',
            root: instance,
            parent: instance
          ),
          root: instance,
          parent: instance
        },
        'c' => {
          label: 'c',
          rocket: 'spacehawk',
          spaceship: 'martyr',
          boomer: 'SPACEHAWK',
          vehicle: 'martyr',
          erased: 'forever',
          postfix: 'X',
          root: instance,
          parent: instance
        },
        't' => {
          label: 't',
          rocket: 'spacehawk',
          spaceship: 'martyr',
          rumba: 'SPACEHAWKX',
          postfix: 'X',
          erased: 'forever',
          root: instance,
          parent: instance
        }
      }
    end

    context 'when using constructor block' do
      let(:instance) do
        composite_class.new(parameters) do
          artifact(
            A,
            filter(:override) { { rumba: artifacts['c'].params[:boomer] + options[:postfix] } } &
            { label: 't' }
          )
        end
      end

      it_behaves_like 'an artifact storage'
    end

    context 'when using instance components method' do
      let(:instance) do
        composite_class.new(parameters).components do
          artifact(
            A,
            filter(:override) { { rumba: artifacts['c'].params[:boomer] + options[:postfix] } } &
            { label: 't' }
          )
        end
      end

      it_behaves_like 'an artifact storage'
    end

    context 'when using subclass' do
      let(:subclass) do
        Class.new(composite_class) do
          components do
            artifact(
              A,
              filter(:override) { { rumba: artifacts['c'].params[:boomer] + options[:postfix] } } &
              { label: 't' }
            )
          end
        end
      end

      let(:instance) { subclass.new(parameters) }

      it_behaves_like 'an artifact storage'
    end
  end
end
