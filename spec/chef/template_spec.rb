require 'spec_helper'

require 'chef/resource/lxc'
require 'chef/provider/lxc'
require 'mixlib/shellout'

describe 'Chef lxc resource/provider' do

  before(:all) do
    execute_recipe('template.rb')
  end

  let(:ct) do
    LXC::Container.new('chef')
  end

  it 'container should be created' do
    expect(ct.defined?).to be_true
  end

  it 'container should be running' do
    expect(ct.running?).to be_true
  end

  it 'container should be ubuntu 10.04' do
    version = ct.execute do
        `lsb_release -a`
      end
    expect(version).to match(/10\.04/)
  end
end
