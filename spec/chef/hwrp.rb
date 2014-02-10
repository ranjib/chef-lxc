require 'spec_helper'

require 'chef/resource/lxc'
require 'chef/provider/lxc'
require 'mixlib/shellout'

describe 'Chef lxc resource/provider' do
  it 'should create and start a container' do
    recipe_file = File.expand_path('../../data/simple_container.rb', __FILE__)
    chef_apply = Mixlib::ShellOut.new('/home/ranjib/.rbenv/shims/bundle exec chef-apply '+ recipe_file)
    chef_apply.live_stream=$stdout
    chef_apply.run_command
    expect(chef_apply.exitstatus).to eq(0)
  end
end
