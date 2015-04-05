# Chef::Lxc

[Chef](http://www.getchef.com/) integration for [LXC](http://linuxcontainers.org/).

## Installation
This library depends on [ruby-lxc](https://github.com/lxc/ruby-lxc), a native liblxc binding.

Use standard rubygem way to install chef-lxc

    $ gem install chef-lxc

## Usage

There are three ways you can use chef-lxc.
* Use the command line tool
* Use the lxc resource/provider from any chef recipe
* Use the Chef::LXCHelper module from any arbitrary ruby script.

### CLI examples

- Execute a chef recipe against a running container (like chef-apply)
  ```sh
  lxc-create -n test -t ubuntu
  lxc-start -n test -d
  chef-lxc test -e 'package "screen"' # via command line
  ```
or stream a recipe
  ```sh
  echo 'package "vim"' | sudo bundle exec chef-lxc chef -s
  ```
or supply a file
  ```sh
  chef-lxc test /path/to/recipe.rb
  ```
### Chef resource/provider examples

- Create & manage containers (inside chef recipes), named `web`
  ```ruby
  require 'chef/lxc'
  lxc "web"
  ```
A more elaborate example,
  ```ruby
  require 'chef/lxc'

  lxc "web" do
    template "ubuntu"

    recipe do
      package "apache2"
      service "apache2" do
        action [:start, :enable]
      end
    end

    action [:create, :start]
  end
  ```

### Use Chef-Lxc from arbitrary ruby code
- Install openssh-server package on a vanilla un-privileged ubuntu container and change the default ubuntu user's password

  ```ruby
  require 'lxc'
  require 'chef'
  require 'chef/lxc'

  include Chef::LXCHelper

  ct = LXC::Container.new('foo')
  ct.create('download', nil, {}, 0, %w{-a amd64 -r trusty -d ubuntu}) # reference: http://www.rubydoc.info/gems/ruby-lxc/LXC/Container#create-instance_method
  ct.start
  sleep 5 # wait till network is up and DHCP allocates the IP
  recipe_in_container(ct) do
    package 'openssh-server'
    execute 'echo "ubuntu:ubuntu" | chpasswd'
  end
  ```

### Automating multi container setup
Chef-LXC provides `Chef::LXC.create_fleet` method to build chef managed
multi container system. It offers helper methods to create containers and perform common 
chef administrative operations like creating roles, environments, databags etc. Combining
`Chef::LXC::Fleet` along with ancillay chef tools like [chef-zero](https://github.com/chef/chef-zero)
and [berkshelf](http://berkshelf.com/), we can test and prototype chef-solo or chef-client/server
managed infrastructure easily.

Following is an example:

  ```ruby
  require 'chef/lxc'
  require 'chef_zero/server'
  require 'tempfile'
  require 'berkshelf'

  cookbook_path = File.expand_path('/tmp/cookbooks')

  # Use berkshelf to venodirze cookbooks
  berksfile = Berkshelf::Berksfile.from_file('/path/to/Berksfile')
  berksfile.vendor('/tmp/cookbooks')

  # Use chef zero as chef server, tell chef-zero to bind on lxcbr interface
  server = ChefZero::Server.new(host: '10.0.3.1', port: 8889)
  server.start_background

  # Generate temporary client key for knife operations
  tempfile = Tempfile.new('chef-lxc')
  File.open(tempfile.path, 'w') do |f|
    f.write(server.gen_key_pair.first)
  end


  Chef::LXC.create_fleet('memcache') do |fleet|
    # Create base container with chef installed in it
    fleet.create_container('base') do |ct|
      ct.recipe do
        execute 'apt-get update -y'
        remote_file '/opt/chef_12.2.1-1_amd64.deb' do
          source 'http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/13.04/x86_64/chef_12.2.1-1_amd64.deb'
        end
        dpkg_package 'chef' do
          source '/opt/chef_12.2.1-1_amd64.deb'
        end
        directory '/etc/chef'
        file '/etc/chef/client.pem' do
          content ChefZero::Server.new.gen_key_pair.first
        end
        file '/etc/chef/client.rb' do
          content "chef_server_url 'http://10.0.3.1:8889'\n"
        end
      end
    end

    # configure chef setting for the chef zero server
    fleet.chef_config do |config|
      config[:client_key] = tempfile.path
      config[:node_name] = 'test'
      config[:chef_server_url] = 'http://10.0.3.1:8889'
    end

    # Upload cookbooks, data bags, create roles
    fleet.upload_cookbooks(cookbook_path)
    fleet.create_role('memcached', 'recipe[memcached]')
    fleet.create_container('memcached', from: 'base') do |ct|
      ct.command('chef-client -r role[memcached]')
    end
  end

  tempfile.unlink
  server.stop
  ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
