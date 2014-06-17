require 'chef/provider'
require 'lxc'

class Chef
  class Provider
    class Lxc < Chef::Provider

      attr_reader :ct

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        @ct = ::LXC::Container.new(new_resource.container_name)
        if (new_resource.action == 'start') or (new_resource.action == 'stop')
          raise ArgumentError, 'Can not start or stop non-existent container'
        end
      end

      def action_create
        unless ct.defined?
          converge_by("create container '#{ct.name}'") do
            template = new_resource.lxc_template.type
            template_options = new_resource.lxc_template.options
            flags = 0
            ct.create(
              new_resource.lxc_template.type,
              new_resource.block_device,
              new_resource.bdev_specs,
              new_resource.flags,
              new_resource.lxc_template.options
            )
          end
        end
      end

      def action_stop
        if ct.running?
          converge_by("stop container '#{ct.name}'") do
            ct.stop
          end
        end
      end

      def action_start
        unless ct.running?
          converge_by("start container '#{ct.name}'") do
            ct.start
          end
        end
        unless new_resource.recipe_block.nil?
          run_recipe
        end
      end

      def action_destroy
        if ct.defined?
          converge_by("destroy container '#{ct.name}'") do
            ct.destroy
          end
        end
      end

      def run_recipe
        client.ohai.load_plugins
        ct.execute do
          Chef::Config[:solo] = true
          client.run_ohai
          client.load_node
          client.build_node
          run_context = Chef::RunContext.new(client.node, {}, client.events)
          recipe = Chef::Recipe.new(new_resource.name,'inline', run_context)
          recipe.instance_eval(&new_resource.recipe_block)
          runner = Chef::Runner.new(run_context)
          runner.converge
        end
      end

      def client
        @client ||= Class.new(Chef::Client) do
          def run_ohai
            ohai.run_plugins
          end
        end.new
      end
    end
  end
end
