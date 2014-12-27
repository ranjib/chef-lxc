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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
