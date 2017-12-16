require 'spec_helper'
require 'aws/templates/render'

describe Aws::Templates::Render do
  let(:render) do
    Module.new { extend Aws::Templates::Render }
  end

  let(:artifact_class) { Class.new }

  let(:child_artifact_class1) { Class.new(artifact_class) }

  let(:child_artifact_class2) { Class.new(artifact_class) }

  let(:unknown_artifact) { Class.new }

  let(:view1) do
    k = Class.new(Aws::Templates::Render::View) do
      def initialize(arg, params); end

      def to_rendered
        'Render 1'
      end
    end

    k.register_in(render).artifact(artifact_class)
  end

  let(:view2) do
    k = Class.new(view1) do
      def to_rendered
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
    expect(render.view_for(artifact_class.new).to_rendered).to be == 'Render 1'
  end

  it 'renders child class correctly' do
    expect(render.view_for(child_artifact_class1.new).to_rendered)
      .to be == 'Render 2'
  end

  it 'renders yet another child class correctly' do
    expect(render.view_for(child_artifact_class2.new).to_rendered)
      .to be == 'Render 1'
  end

  it 'throws an error once no classes are found' do
    expect { render.view_for(unknown_artifact.new).to_rendered }
      .to raise_error Aws::Templates::Exception::ViewNotFound
  end
end
