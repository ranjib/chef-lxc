# Chef::Lxc

[Chef](http://www.getchef.com/) integration for [LXC](http://linuxcontainers.org/).

## Installation
Note: This library depends on [ruby-lxc](https://github.com/lxc/ruby-lxc), a native liblxc binding, ruby-lxc will be
released around April, 2014(alongside LXC 1.0, Ubuntu 14.04 release). Till then,
use bundler to experiement with chef-lxc.

Add this line to your application's Gemfile:

    gem 'chef-lxc', github: 'ranjib/chef-lxc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chef-lxc

## Usage
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

- Create & manage containers (inside chef recipes)
Following will create a default (ubuntu) container named `web`
  ```ruby
  lxc "web"
  ```
A more elaborate example,
  ```ruby
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
