require 'spec_helper'
require 'chef/application/lxc'

describe Chef::Application::LXC do
  before(:all) do
    c = LXC::Container.new('test')
    c.create('download', nil, {}, 0, %w{-d ubuntu -r trusty -a amd64}) unless c.defined?
    c.start unless c.running?
  end
  after(:all) do
    destroy_ct
  end
  it 'should install a package inside a container' do
    app = Chef::Application::LXC.new
    app.config[:execute] = 'execute "apt-get update -y"'
    ARGV.clear
    ARGV << 'test'
    expect do
      app.run_chef_recipe
    end.to_not raise_error
  end
end
