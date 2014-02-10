require 'spec_helper'

require 'chef/resource/lxc'
require 'chef/provider/lxc'
require 'mixlib/shellout'

describe 'Chef lxc resource/provider' do

  before(:all) do
    execute_recipe('simple.rb')
  end

  let(:ct) do
    LXC::Container.new('chef')
  end

  it 'should create the container' do
    expect(ct.defined?).to be_true
  end

  it 'should not start the container' do
    expect(ct.running?).to be_false
  end
end
