require 'spec_helper'

describe 'couchdb' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:root_home) { '/root' }

      it { is_expected.to compile }
      it { is_expected.to contain_couchdb }
      it { is_expected.to contain_couchdb_instance('main') }
    end
  end
end
