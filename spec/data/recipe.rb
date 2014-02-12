require 'chef/lxc'

lxc 'chef' do
  recipe do

    directory '/opt/test'

    package 'apache2'

    service 'apache2' do
      action [:start, :enable]
    end
  end
  action [:create, :start]
end
