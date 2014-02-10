
require 'chef/lxc'
require 'serverspec'

include SpecInfra::Helper::Lxc
include SpecInfra::Helper::Debian


module LXCSpecHelper
  def execute_recipe(recipe)
    c = LXC::Container.new('chef')
    c.stop if c.running?
    c.destroy if c.defined?
    recipe_file = File.expand_path('../data/' + recipe, __FILE__)
    command = Mixlib::ShellOut.new('chef-apply '+ recipe_file, timeout: 20*60)
    command.live_stream=$stdout
    command.run_command
    command
  end
end

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.filter_run(focus: true)
  config.include LXCSpecHelper
  config.run_all_when_everything_filtered = true
  config.lxc = "chef"
  config.backtrace_exclusion_patterns = []
end
