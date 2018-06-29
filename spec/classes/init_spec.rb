require 'spec_helper'
describe 'couchdb' do
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('couchdb') }
  end
end
