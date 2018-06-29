require 'spec_helper'

describe 'couchdb' do
  let(:facts) do
    {
      :osfamily => 'Debian' ,
      :operatingsystem => 'Linux' 
    }
  end
  it { is_expected.to compile }
end
