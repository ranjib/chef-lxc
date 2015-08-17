require 'chef/lxc'
require 'pry'

module LXCSpecHelper
  def execute_recipe(recipe)
    c = LXC::Container.new('chef')
    c.stop if c.running?
    c.destroy if c.defined?
    recipe_file = File.expand_path('../data/' + recipe, __FILE__)
    command = Mixlib::ShellOut.new('chef-apply '+ recipe_file, timeout: 20*60)
    command.live_stream=$stdout if STDIN.tty?
    command.run_command
    command
  end
  def destroy_ct
    c = LXC::Container.new('chef')
    c.stop if c.running?
    c.destroy if c.defined?
  end
end

module ChefSpecHelper
  def self.new_server
    ChefZero::Server.new(host: '10.0.3.1', port: 8889)
  end

  def self.create_fleet(server)
    server.start_background unless server.running?
    tempfile = Tempfile.new('chef-lxc')
    File.open(tempfile.path, 'w') do |f|
      f.write(server.gen_key_pair.first)
    end

    Chef::LXC.create_fleet('chef-helper') do |fleet|
      fleet.chef_config do |config|
        config[:client_key] = tempfile.path
        config[:node_name] = 'test'
        config[:chef_server_url] = server.url
      end
    end
  end
end

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.filter_run(focus: true)
  config.include LXCSpecHelper
  config.run_all_when_everything_filtered = true
  config.backtrace_exclusion_patterns = []
end
