require 'chef'
require 'chef/environment'
require 'chef/role'
require 'chef/knife/cookbook_upload'
require 'chef/knife/data_bag_from_file'
require 'chef/knife/data_bag_create'
require 'chef/lxc/container_helper'
require 'chef/lxc/knife_helper'

class Chef
  module LXC
    class Fleet
      include Chef::LXC::KnifeHelper

      def create_container(name, opts = {})
        from = opts[:from]
        force = opts[:force]
        ct = container(name)
        if ct.defined? and force
          ct.stop if ct.running?
          ct.destroy
          ct = container(name)
        end
        if from
          base = container(from)
          base.clone(name)
          ct = container(name)
        else
          template = opts[:template] || 'download'
          bdevtype = opts[:bdevtype]
          bdevspecs = opts[:bdevspecs] || {}
          flags = opts[:flags] || 0
          args = opts[:flags] || %w(-d ubuntu -r trusty -a amd64)
          ct.create(template, bdevtype, bdevspecs, flags, args)
        end
        ct.start unless ct.running?
        while ct.ip_addresses.empty?
          sleep 1
        end
        yield ct if block_given?
        ct.stop
        ct
      end

      def container(name)
        ct = ::LXC::Container.new(name)
        ct.extend Chef::LXC::ContainerHelper
        ct
      end
    end
  end
end
