require 'chef/lxc'

lxc "chef" do

  template "ubuntu" do
    args %w{-r lucid}
  end

  action [:create, :start]
end
