require 'mixlib/shellout'
require 'chef/lxc_helper'

class Chef
  module LXC
    module ContainerHelper
      include Chef::LXCHelper

      def recipe(path = nil, &block)
        recipe_content = path ? File.read(path) : nil
        recipe_in_container(self, recipe_content, &block)
      end

      def command(command)
        out = execute(wait: true) do
          cmd = Mixlib::ShellOut.new(command)
          cmd.live_stream = $stdout
          cmd.run_command
          cmd.exitstatus
        end
        out
      end
    end
  end
end
