require 'lxc'
require 'lxc/extra'

class Chef
  module LXCHelper
    def recipe_in_container(ct, options={})
      client = Class.new(Chef::Client) do
        def run_ohai
          ohai.run_plugins
        end
      end.new
      client.ohai.load_plugins
      ct.execute do
        Chef::Config[:solo] = true
        client.run_ohai
        client.load_node
        client.build_node
        run_context = Chef::RunContext.new(client.node, {}, client.events)
        recipe = Chef::Recipe.new("chef-loxc-cookbook", "chef-lxc-recipe", run_context)
        if options[:block]
          recipe.instance_eval(&new_resource.recipe_block)
        elsif options[:text]
          recipe.instance_eval(options[:text], __FILE__, __LINE__)
        else
        end
        runner = Chef::Runner.new(run_context)
        runner.converge
      end
    end
  end
end
