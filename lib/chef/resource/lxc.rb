require 'chef/resource'

class Chef
  class Resource
    class Lxc < Chef::Resource

      class LXCTemplate
        attr_reader :type, :options

        def initialize(type='download')
          @type = type
          @options = %w{-d ubuntu -r trusty -a amd64}
        end

        def args(args)
          @options = args
        end
      end

      identity_attr :container_name
      attr_reader :lxc_template, :recipe_block

      def initialize(name, run_context = nil)
        super
        @resource_name = :container
        @container_name = name
        @provider = Chef::Provider::Lxc
        @action = :create
        @allowed_actions += [:start, :stop, :destroy, :create, :reboot]
        @lxc_template = LXCTemplate.new
        @recipe_block = nil
        @block_device = nil
        @bdev_specs = {}
        @flags = 0
        @config = {}
        @wait_for_network = true
        @config_path = nil
      end

      def config_path(arg = nil)
        set_or_return(:config_path, arg, kind_of: [ String ] )
      end

      def container_name(arg = nil)
        set_or_return(:container_name, arg, kind_of: [ String ] )
      end

      def wait_for_network(arg = nil)
        set_or_return(:wait_for_network, arg, kind_of: [ TrueClass, FalseClass ] )
      end

      def config(arg=nil)
        set_or_return(:config, arg, kind_of: [ Hash ] )
      end

      def flags(arg = nil)
        set_or_return(:flags, arg, kind_of: [ Fixnum ] )
      end

      def block_device(arg = nil)
        set_or_return(:block_device, arg, kind_of: [ String ] )
      end

      def bdev_specs(arg = nil)
        set_or_return(:bdev_specs, arg, kind_of: [ Hash ] )
      end

      def template(type = 'ubuntu', &block)
        @lxc_template = LXCTemplate.new(type)
        if block_given?
          @lxc_template.instance_eval(&block)
        end
      end

      def recipe(&block)
        @recipe_block = block
      end
    end
  end
end
