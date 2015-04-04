require 'chef/lxc_helper'
require 'chef/resource/lxc'
require 'chef/provider/lxc'
require 'chef/lxc/fleet'

class Chef
  module LXC
    def self.create_fleet(name)
      fleet = Chef::LXC::Fleet.new
      yield fleet if block_given?
      fleet
    end
  end
end
