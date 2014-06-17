require 'chef/lxc'

lxc "chef" do

  template "download" do
    args %w{-r lucid -d ubuntu -a amd64}
  end

  action [:create, :start]
end
