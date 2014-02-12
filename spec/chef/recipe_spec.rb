require 'spec_helper'

require 'chef/resource/lxc'
require 'chef/provider/lxc'
require 'mixlib/shellout'

describe 'inline recipe' do

  before(:all) do
    execute_recipe('recipe.rb')
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

  it 'should create test directory' do
    expect(file('/opt/test')).to be_directory
  end

  it 'should install apach2 package' do
    expect(package('apache2')).to be_installed
  end

  it 'should start apache2 service' do
    expect(service('apache2')).to be_running
  end

  it 'should enable apache2 service' do
    expect(service('apache2')).to be_enabled
  end
end
