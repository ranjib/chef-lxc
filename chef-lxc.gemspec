# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chef/lxc/version'

Gem::Specification.new do |spec|
  spec.name          = "chef-lxc"
  spec.version       = Chef::LXC::VERSION
  spec.authors       = ["Ranjib Dey"]
  spec.email         = ["ranjib@linux.com"]
  spec.description   = %q{LXC bindings for Chef}
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir        = "bin"

  spec.add_dependency "chef"
  spec.add_dependency "ruby-lxc"
  spec.add_dependency "lxc-extra"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "chef-zero"
end
