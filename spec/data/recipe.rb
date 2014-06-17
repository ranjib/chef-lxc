require 'chef/lxc'

lxc 'chef' do

  template 'download' do
    args ['-d', 'ubuntu', '-r', 'lucid', '-a', 'amd64']
  end

  recipe do
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
