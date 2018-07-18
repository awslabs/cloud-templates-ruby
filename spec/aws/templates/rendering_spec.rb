require 'spec_helper'
require 'aws/templates/rendering/render'

describe Aws::Templates::Rendering do
  let(:render_class) do
    Class.new(Aws::Templates::Rendering::Render)
  end

  let(:render) { render_class.new }

  let(:artifact_class) { Class.new }

  let(:child_artifact_class1) { Class.new(artifact_class) }

  let(:child_artifact_class2) { Class.new(artifact_class) }

  let(:unknown_artifact) { Class.new }

  let(:view1) do
    k = Class.new(Aws::Templates::Rendering::View) do
      def to_processed
        'Render 1'
      end
    end

    k.register_in(render_class).artifact(artifact_class)
  end

  let(:view2) do
    k = Class.new(view1) do
      def to_processed
        'Render 2'
      end
    end

    k.artifact(child_artifact_class1)
  end

  before do
    view1
    view2
  end

  it 'renders class correctly' do
    expect(render.process(artifact_class.new)).to be == 'Render 1'
  end

  it 'renders child class correctly' do
    expect(render.process(child_artifact_class1.new))
      .to be == 'Render 2'
  end

  it 'renders yet another child class correctly' do
    expect(render.process(child_artifact_class2.new))
      .to be == 'Render 1'
  end

  it 'throws an error once no classes are found' do
    expect { render.process(unknown_artifact.new) }
      .to raise_error Aws::Templates::Exception::ViewNotFound
  end
end
