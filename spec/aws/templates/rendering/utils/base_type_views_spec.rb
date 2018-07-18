require 'spec_helper'
require 'aws/templates/rendering/utils/base_type_views'
require 'aws/templates/rendering/render'

describe Aws::Templates::Rendering::Utils::BaseTypeViews do
  let(:render_class) do
    Class.new(Aws::Templates::Rendering::Render)
  end

  let(:render) do
    render_class.new
  end

  describe 'AsIs' do
    before do
      render_class.define_view(Object, Aws::Templates::Rendering::Utils::BaseTypeViews::AsIs)
    end

    it 'renders string' do
      expect(render.process('123')).to be == '123'
    end

    it 'renders random object' do
      expect(render.process([123])).to be == [123]
    end
  end

  describe 'ToString' do
    before do
      render_class.define_view(Object, Aws::Templates::Rendering::Utils::BaseTypeViews::ToString)
    end

    it 'renders string' do
      expect(render.process('123')).to be == '123'
    end

    it 'renders number' do
      expect(render.process(123)).to be == '123'
    end
  end

  describe 'ToArray' do
    before do
      render_class.define_view(Array, Aws::Templates::Rendering::Utils::BaseTypeViews::ToArray)
      render_class.define_view(Object, Aws::Templates::Rendering::Utils::BaseTypeViews::ToString)
    end

    it 'renders array' do
      expect(render.process([[1, 2, 3], '123'])).to be == [%w[1 2 3], '123']
    end
  end

  describe 'ToHash' do
    before do
      render_class.define_view(Object, Aws::Templates::Rendering::Utils::BaseTypeViews::ToString)
      render_class.define_view(Hash, Aws::Templates::Rendering::Utils::BaseTypeViews::ToHash)
    end

    it 'renders hash' do
      expect(render.process(q: 1, w: { e: 2, r: 3 }))
        .to be == { 'q' => '1', 'w' => { 'e' => '2', 'r' => '3' } }
    end
  end

  describe 'ToFloat' do
    before do
      render_class.define_view(Object, Aws::Templates::Rendering::Utils::BaseTypeViews::ToFloat)
    end

    it 'renders integer' do
      expect(render.process(1)).to be == 1.0
    end

    it 'renders string' do
      expect(render.process('1.3')).to be == 1.3
    end
  end

  describe 'ToInteger' do
    before do
      render_class.define_view(Object, Aws::Templates::Rendering::Utils::BaseTypeViews::ToInteger)
    end

    it 'renders float' do
      expect(render.process(1.3)).to be == 1
    end

    it 'renders string' do
      expect(render.process('23')).to be == 23
    end
  end

  describe 'ToBoolean' do
    before do
      render_class.define_view(Object, Aws::Templates::Rendering::Utils::BaseTypeViews::ToBoolean)
    end

    it 'renders random object' do
      expect(render.process([])).to be == true
    end

    it 'renders false' do
      expect(render.process(false)).to be == false
    end

    it 'renders false as a string' do
      expect(render.process('false')).to be == false
    end

    it 'renders true' do
      expect(render.process(true)).to be == true
    end
  end
end
