require 'spec_helper'

describe 'couchdb' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          root_home: '/root',
        )
      end

      it { is_expected.to compile }
    end
  end
end
