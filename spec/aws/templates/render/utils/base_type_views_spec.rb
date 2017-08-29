require 'spec_helper'
require 'aws/templates/render/utils/base_type_views'
require 'aws/templates/render'

include Aws::Templates::Render::Utils::BaseTypeViews

describe Aws::Templates::Render::Utils::BaseTypeViews do
  let(:render) do
    Module.new do
      extend Aws::Templates::Render
    end
  end

  describe 'AsIs' do
    before { render.define_view(Object, AsIs) }

    it 'renders string' do
      expect(render.view_for('123').to_rendered).to be == '123'
    end

    it 'renders random object' do
      expect(render.view_for([123]).to_rendered).to be == [123]
    end
  end

  describe 'ToString' do
    before { render.define_view(Object, ToString) }

    it 'renders string' do
      expect(render.view_for('123').to_rendered).to be == '123'
    end

    it 'renders number' do
      expect(render.view_for(123).to_rendered).to be == '123'
    end
  end

  describe 'ToArray' do
    before do
      render.define_view(Array, ToArray)
      render.define_view(Object, ToString)
    end

    it 'renders array' do
      expect(render.view_for([[1, 2, 3], '123']).to_rendered).to be == [%w(1 2 3), '123']
    end
  end

  describe 'ToHash' do
    before do
      render.define_view(Object, ToString)
      render.define_view(Hash, ToHash)
    end

    it 'renders hash' do
      expect(render.view_for(q: 1, w: { e: 2, r: 3 }).to_rendered)
        .to be == { 'q' => '1', 'w' => { 'e' => '2', 'r' => '3' } }
    end
  end

  describe 'ToFloat' do
    before { render.define_view(Object, ToFloat) }

    it 'renders integer' do
      expect(render.view_for(1).to_rendered).to be == 1.0
    end

    it 'renders string' do
      expect(render.view_for('1.3').to_rendered).to be == 1.3
    end
  end

  describe 'ToInteger' do
    before { render.define_view(Object, ToInteger) }

    it 'renders float' do
      expect(render.view_for(1.3).to_rendered).to be == 1
    end

    it 'renders string' do
      expect(render.view_for('23').to_rendered).to be == 23
    end
  end

  describe 'ToBoolean' do
    before { render.define_view(Object, ToBoolean) }

    it 'renders random object' do
      expect(render.view_for([]).to_rendered).to be == true
    end

    it 'renders false' do
      expect(render.view_for(false).to_rendered).to be == false
    end

    it 'renders false as a string' do
      expect(render.view_for('false').to_rendered).to be == false
    end

    it 'renders true' do
      expect(render.view_for(true).to_rendered).to be == true
    end
  end
end
