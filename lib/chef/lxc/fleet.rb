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
        force = opts[:force]
        ct = container(name)
        if ct.defined?
          if force
            ct.stop if ct.running?
            ct.destroy
            ct = provision(name, opts)
          end
        else
          ct = provision(name, opts)
        end
        ct.start unless ct.running?
        while ct.ip_addresses.empty?
          sleep 1
        end
        yield ct if block_given?
        ct.stop if opts[:stop_after]
        ct
      end

      def container(name)
        ct = ::LXC::Container.new(name)
        ct.extend Chef::LXC::ContainerHelper
        ct
      end

      def provision(name, opts = {})
        from = opts[:from]
        if from
          base = container(from)
          base.clone(name)
        else
          template = opts[:template] || 'download'
          bdevtype = opts[:bdevtype]
          bdevspecs = opts[:bdevspecs] || {}
          flags = opts[:flags] || 0
          args = opts[:args] || %w(-d ubuntu -r trusty -a amd64)
          ct = container(name)
          ct.create(template, bdevtype, bdevspecs, flags, args)
        end
        container(name)
      end
    end
  end
end
