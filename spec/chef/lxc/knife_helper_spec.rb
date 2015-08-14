require 'spec_helper'

describe Chef::LXC::KnifeHelper do
  before(:each) do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('secret').and_return(true)
    allow(IO).to receive(:read).and_call_original
    allow(IO).to receive(:read).with('secret').and_return('secret_val')
  end

  after(:each) do
    chef_server.stop
  end

  def create_fleet(name)
    chef_server.start_background unless chef_server.running?
    tempfile = Tempfile.new('chef-lxc')
    File.open(tempfile.path, 'w') do |f|
      f.write(chef_server.gen_key_pair.first)
    end

    fleet = Chef::LXC.create_fleet(name)
    fleet.chef_config do |config|
      config[:client_key] = tempfile.path
      config[:node_name] = 'test'
      config[:chef_server_url] = 'http://10.0.3.1:8889'
      config[:encrypted_data_bag_secret] = 'secret'
    end

    fleet
  end

  def create_data_bag(data_bag_name, hash, opts = {})
    fleet.create_data_bag(data_bag_name)
    fleet.upload_data_bag_item_from_hash(data_bag_name, hash, opts)
  end

  let(:chef_server) { ChefZero::Server.new(host: '10.0.3.1', port: 8889) }
  let(:fleet) { create_fleet('knife-helper') }
  let(:data_bag_name) { :data_bag_name }
  let(:item_name) { :item_name }

  context('#update_data_bag_item') do
    it 'adds new keys to data bag item (encrypted)' do
      opts = {encrypted: true}
      create_data_bag(data_bag_name, {'id' => item_name}, opts)

      fleet.update_data_bag_item(data_bag_name, item_name, {a: :b}, opts)

      secrets = Chef::EncryptedDataBagItem.load(data_bag_name, item_name)
      expect(secrets['a']).to eq('b')
    end

    it 'overwrites old keys in data bag item (encrypted)' do
      opts = {encrypted: true}
      existing_data = {'id' => item_name, a: :c}
      create_data_bag(data_bag_name, existing_data, opts)

      fleet.update_data_bag_item(data_bag_name, item_name, {a: :b}, opts)

      secrets = Chef::EncryptedDataBagItem.load(data_bag_name, item_name)
      expect(secrets['a']).to eq('b')
    end

    it 'adds new keys to data bag item (unencrypted)' do
      opts = {}
      create_data_bag(data_bag_name, {'id' => item_name}, opts)

      fleet.update_data_bag_item(data_bag_name, item_name, {a: :b}, opts)

      secrets = Chef::DataBagItem.load(data_bag_name, item_name)
      expect(secrets['a']).to eq('b')
    end

    it 'overwrites old keys in data bag item (unencrypted)' do
      opts = {}
      existing_data = {'id' => item_name, a: :c}
      create_data_bag(data_bag_name, existing_data, opts)

      fleet.update_data_bag_item(data_bag_name, item_name, {a: :b}, opts)

      secrets = Chef::DataBagItem.load(data_bag_name, item_name)
      expect(secrets['a']).to eq('b')
    end
  end
end
