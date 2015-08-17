require 'chef/lxc'
require 'chef_zero/server'
require 'tempfile'

require 'spec_helper'

cookbook_path = File.expand_path('../../../data/cookbooks', __FILE__)

describe(:fleet_dsl) do
  let(:server) { ChefSpecHelper.new_server }
  let(:fleet) { ChefSpecHelper.create_fleet(server) }

  after(:each) do
    server.stop if server.running?
  end

  it 'succeeds' do
    # Upload cookbooks, data bags, create roles
    fleet.upload_cookbooks(cookbook_path)
    fleet.create_role('memcached', 'recipe[memcached]')

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
      ct.stop
    end

    fleet.create_container('memcached', from: 'base') do |ct|
      ct.command!('chef-client -r role[memcached]')
      ct.stop
    end
  end
end
