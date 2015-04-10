require 'spec_helper'
require 'chef/lxc/fleet'

describe Chef::LXC::Fleet do
  let(:fleet) do
    described_class.new
  end
  context '#create_container' do
    it 'new container' do
      ct = double(::LXC::Container, defined?: false, start: true, stop: true, running?: true)
      expect(ct).to receive(:create).with(
        'download', nil, {}, 0, %w(-d ubuntu -r trusty -a amd64)
      )
      expect(ct).to receive(:ip_addresses).and_return(['192.168.2.1'])
      allow(::LXC::Container).to receive(:new).and_return(ct)
      fleet.create_container('test-container')
    end

    it 'clone' do
      ct = double(::LXC::Container, defined?: false, start: true, stop: true, running?: true)
      base = double(::LXC::Container)
      expect(base).to receive(:clone)
      expect(ct).to receive(:ip_addresses).and_return(['192.168.2.1'])
      allow(::LXC::Container).to receive(:new).and_call_original
      allow(::LXC::Container).to receive(:new).with('baz').and_return(base)
      allow(::LXC::Container).to receive(:new).with('test-foo').and_return(ct)
      fleet.create_container('test-foo', from: 'baz')
    end

    it 'recreate' do
      ct = double(::LXC::Container, defined?: true, start: true, stop: true, running?: true)
      expect(ct).to receive(:destroy)
      expect(ct).to receive(:create).with(
        'download', nil, {}, 0, %w(-d ubuntu -r trusty -a amd64)
      )
      expect(ct).to receive(:ip_addresses).and_return(['192.168.2.1'])
      allow(::LXC::Container).to receive(:new).with('test-foo').and_return(ct)
      fleet.create_container('test-foo', force: true)
    end

    it 'clone and recreate' do
      ct = double(::LXC::Container, defined?: true, start: true, stop: true, running?: true)
      expect(ct).to receive(:destroy)
      base = double(::LXC::Container)
      expect(base).to receive(:clone)
      expect(ct).to receive(:ip_addresses).and_return(['192.168.2.1'])
      allow(::LXC::Container).to receive(:new).and_call_original
      allow(::LXC::Container).to receive(:new).with('baz').and_return(base)
      allow(::LXC::Container).to receive(:new).with('test-foo').and_return(ct)
      fleet.create_container('test-foo', force: true, from: 'baz')
    end
  end

  it '#container' do
    ct = fleet.container('test-container')
    expect(ct).to be_kind_of(::LXC::Container)
    expect(ct.name).to eq('test-container')
    expect(ct).to respond_to(:recipe)
    expect(ct).to respond_to(:command)
  end

  it '#chef_config' do
    fleet.chef_config(client_key: 'test.pem')
    expect(Chef::Config[:client_key]).to eq('test.pem')
  end

  it '#upload_cookbooks' do
    expect_any_instance_of(Chef::Knife::CookbookUpload).to receive(:run)
    plugin = fleet.upload_cookbooks('/path/to/cookbooks', 'a', 'b', 'c')
    expect(plugin.name_args).to eq(%w(a b c))
    expect(plugin.config[:cookbook_path]).to eq(['/path/to/cookbooks'])
    expect(plugin.config[:all]).to be_nil
  end

  it '#create_data_bag' do
    expect_any_instance_of(Chef::Knife::DataBagCreate).to receive(:run)
    plugin = fleet.create_data_bag('test-dbag')
    expect(plugin.name_args).to eq(['test-dbag'])
  end

  it '#upload_data_bag' do
    allow(Dir).to receive(:[]).with('/path/to/dbag/*').and_return(%w(a b c))
    expect_any_instance_of(Chef::Knife::DataBagFromFile).to receive(:run)
    plugin = fleet.upload_data_bag('foo', '/path/to/dbag')
    expect(plugin.name_args).to eq(%w(foo a b c))
  end

  it '#create environment' do
    expect_any_instance_of(Chef::Environment).to receive(:save)
    attrs = {a: 1, b: 2}
    env = fleet.create_environment('test-env', default_attributes: attrs)
    expect(env.name).to eq('test-env')
    expect(env.default_attributes).to eq(a: 1, b:2)
  end

  it '#create role' do
    expect_any_instance_of(Chef::Role).to receive(:save)
    role = fleet.create_role('test-role', 'recipe[bar]')
    expect(role.name).to eq('test-role')
    expect(role.run_list.count).to eq(1)
    expect(role.run_list.first.to_s).to eq('recipe[bar]')
  end

  context '#provision' do
    it 'uses ubuntu trusty amd64 by default' do
      ct = double(::LXC::Container)
      expect(ct).to receive(:create).with('download', nil,{}, 0, %w(-d ubuntu -r trusty -a amd64))
      expect(::LXC::Container).to receive(:new).with('foo').twice.and_return(ct)
      fleet.provision('foo')
    end

    it 'passes template and template arguments' do
      ct = double(::LXC::Container)
      expect(ct).to receive(:create).with('ubuntu', nil, {}, 0, %w(-r trusty -a amd64))
      expect(::LXC::Container).to receive(:new).with('foo').twice.and_return(ct)
      fleet.provision('foo', template: 'ubuntu', args: %w(-r trusty -a amd64))
    end

    it 'passes bdevtype and specs' do
      ct = double(::LXC::Container)
      expect(ct).to receive(:create).with('download', 'lvm',{baz: :bar}, 0, %w(-d ubuntu -r trusty -a amd64))
      expect(::LXC::Container).to receive(:new).with('foo').twice.and_return(ct)
      fleet.provision('foo', bdevtype: 'lvm', bdevspecs: {baz: :bar})
    end

    it 'passes clone flags' do
      ct = double(::LXC::Container)
      expect(ct).to receive(:create).with('download', nil, {}, 12, %w(-d ubuntu -r trusty -a amd64))
      expect(::LXC::Container).to receive(:new).with('foo').twice.and_return(ct)
      fleet.provision('foo', flags: 12)
    end
  end
end
