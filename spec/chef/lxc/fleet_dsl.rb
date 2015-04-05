require 'chef/lxc'
require 'chef_zero/server'
require 'tempfile'

cookbook_path = File.expand_path('../../../data/cookbooks', __FILE__)
server = ChefZero::Server.new(host: '10.0.3.1', port: 8889)
server.start_background unless server.running?
tempfile = Tempfile.new('chef-lxc')
File.open(tempfile.path, 'w') do |f|
  f.write(server.gen_key_pair.first)
end

Chef::LXC.create_fleet('memcache') do |fleet|
  # Create base container with chef installed in it
  fleet.create_container('base') do |ct|
    ct.recipe do
      execute 'apt-get update -y'
      remote_file '/opt/chef_12.2.1-1_amd64.deb' do
        source 'http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/13.04/x86_64/chef_12.2.1-1_amd64.deb'
      end
      dpkg_package 'chef' do
        source '/opt/chef_12.2.1-1_amd64.deb'
      end
      directory '/etc/chef'
      file '/etc/chef/client.pem' do
        content ChefZero::Server.new.gen_key_pair.first
      end
      file '/etc/chef/client.rb' do
        content "chef_server_url 'http://10.0.3.1:8889'\n"
      end
    end
  end
  
  # configure chef setting for the new chef server
  fleet.chef_config do |config|
    config[:client_key] = tempfile.path
    config[:node_name] = 'test'
    config[:chef_server_url] = 'http://10.0.3.1:8889'
  end
  
  # Upload cookbooks, data bags, create roles 
  fleet.upload_cookbooks(cookbook_path)
  fleet.create_role('memcached', 'recipe[memcached]')
  fleet.create_container('memcached', from: 'base') do |ct|
    ct.command('chef-client -r role[memcached]')
  end
end
