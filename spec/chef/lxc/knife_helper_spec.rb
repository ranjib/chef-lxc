require 'spec_helper'

def create_fleet(name)
  cookbook_path = File.expand_path('../../../data/cookbooks', __FILE__)
  server = ChefZero::Server.new(host: '10.0.3.1', port: 8889)
  server.start_background unless server.running?
  tempfile = Tempfile.new('chef-lxc')
  File.open(tempfile.path, 'w') do |f|
    f.write(server.gen_key_pair.first)
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

describe Chef::LXC::KnifeHelper do
  let(:fleet) { create_fleet('knife-helper') }
  let(:data_bag_name) { :data_bag_name }
  let(:item_name) { :item_name }
  let(:update_value) { {key: 'val'} }

  before(:each) do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('secret').and_return(true)
    allow(IO).to receive(:read).and_call_original
    allow(IO).to receive(:read).with('secret').and_return('secret_val')

    fleet.create_data_bag(data_bag_name)
    item = Chef::DataBagItem.from_hash({'id' => item_name})
    item.data_bag(data_bag_name)
    item.save
  end

  it 'runs update_data_bag_item with encrypted:true successfully' do
    fleet.update_data_bag_item(data_bag_name, item_name, update_value, {encrypted: true})
    secrets = Chef::EncryptedDataBagItem.load(data_bag_name, item_name)
    puts secrets.to_hash
    expect(secrets['key']).to eq('val')
  end
end
