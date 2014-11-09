require 'chef/lxc'

lxc 'chef' do

  template 'download' do
    args ['-d', 'ubuntu', '-r', 'trusty', '-a', 'amd64']
  end

  recipe do
    execute 'sleep 10'
    execute 'apt-get update -y'
    directory '/opt/test'
    package 'apache2' do
      retries 5
    end
    service 'apache2' do
      action [:start, :enable]
    end
  end
  action [:create, :start]
end
