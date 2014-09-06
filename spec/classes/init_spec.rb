require 'spec_helper'
describe 'couchdb' do

  context 'with defaults for all parameters' do
    it { should contain_class('couchdb') }
  end
end
