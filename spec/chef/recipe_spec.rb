require 'spec_helper'

require 'chef/resource/lxc'
require 'chef/provider/lxc'
require 'mixlib/shellout'

describe 'inline recipe' do

  before(:all) do
    execute_recipe('recipe.rb')
  end
  after(:all) do
    destroy_ct
  end

  let(:ct) do
    LXC::Container.new('chef')
  end

  it 'container should be created' do
    expect(ct.defined?).to be(true)
  end

  it 'container should be running' do
    expect(ct.running?).to be(true)
  end

  it 'should create test directory' do
    expect(file('/opt/test')).to be_directory
  end

  it 'should install apach2 package'

  it 'should start apache2 service'

  it 'should enable apache2 service'
end
