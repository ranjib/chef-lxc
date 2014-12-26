require 'lxc'
require 'lxc/extra'

class Chef
  module LXCHelper
    def recipe_in_container(ct, recipe_text = nil, &recipe_block)
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
        recipe.instance_eval(&recipe_block) if recipe_block
        recipe.instance_eval(recipe_text, __FILE__, __LINE__) if recipe_text
        runner = Chef::Runner.new(run_context)
        runner.converge
      end
    end
  end
end
