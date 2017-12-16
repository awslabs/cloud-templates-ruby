require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Utils::Autoload do
  describe 'lazy' do
    let(:test_module) do
      ::Object.lazy::Wert
    end

    it 'doesn\'t have any methods' do
      expect { test_module.rt(1) { 1 } }.to raise_error(NoMethodError, /Lazy.*Wert.*rt.*1.*Proc/m)
    end
  end
end
