require 'spec_helper'
require 'chef/application/lxc'

describe Chef::Application::LXC do
  before(:all) do
    c = LXC::Container.new('test')
    c.create('ubuntu') unless c.defined?
    c.start unless c.running?
  end
  after(:all) do
    c = LXC::Container.new('test')
    c.stop if c.running?
  end
  it 'should install a package inside a container' do
    app = Chef::Application::LXC.new
    app.config[:execute] = 'package "screen"'
    ARGV.clear
    ARGV << 'test'
    expect do
      app.run_chef_recipe
    end.to_not raise_error
  end
end
