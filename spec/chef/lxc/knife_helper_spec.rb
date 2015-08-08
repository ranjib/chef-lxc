require 'spec_helper'

class KnifeHelperClass
  include Chef::LXC::KnifeHelper
end

describe Chef::LXC::KnifeHelper do
  let(:helper) do
    KnifeHelperClass.new
  end

  before(:each) do
    helper.chef_config(
      chef_server_url: 'localhost',
      encrypted_data_bag_secret: 'secret',
    )
    allow(Chef::REST).to receive(:new).and_return(double().as_null_object)
    allow(File).to receive(:exist?).with('secret').and_return(true)
    allow(IO).to receive(:read).with('secret').and_return('secret_val')
  end

  let(:data_bag_name) { :data_bag_name }
  let(:item_name) { :item_name }
  let(:update_value) { {key: 'val'} }

  it 'runs update_data_bag_item with encrypted:true successfully' do
    allow(Chef::DataBagItem).to receive(:load)
      .with(data_bag_name, item_name)
      .and_return({'id' => item_name})
    helper.update_data_bag_item(data_bag_name, item_name, update_value, {encrypted: true})
  end
end
