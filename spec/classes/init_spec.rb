require 'spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts
describe 'couchdb' do
  it { is_expected.to compile }
  context 'with defaults' do
    it { is_expected.to contain_class('couchdb::instance') }
  end
end
