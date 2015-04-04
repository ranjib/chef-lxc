class Chef
  module LXC
    module KnifeHelper
      def knife(klass, *args)
        klass.load_deps
        plugin = klass.new
        plugin.name_args = args
        yield plugin.config if block_given?
        plugin.run
        plugin
      end

      def chef_config(config = {})
        config.each do |key, value|
          Chef::Config[key] = value
        end
        yield Chef::Config if block_given?
        Chef::Config
      end

      def upload_cookbooks(path, *cookbooks)
        cookbook_dirs = Array(path)
        knife Chef::Knife::CookbookUpload, *cookbooks do |config|
          config[:all] = true if cookbooks.empty?
          config[:cookbook_path] = cookbook_dirs
        end
      end

      def create_data_bag(name)
        knife Chef::Knife::DataBagCreate, name
      end

      def upload_data_bag(name, path, opts = {})
        items = Dir["#{path}/*"]
        name_args = [name, items].flatten
        plugin = knife(Chef::Knife::DataBagFromFile, *name_args)do |config|
          if opts[:encrypted]
            config[:secret_file] = opts[:secret_file]
            config[:encrypt] = true
            Chef::Config[:knife][:secret_file] = opts[:secret_file]
          end
        end
      end

      def create_environment(name, opts ={})
        e = Chef::Environment.new
        e.name(name)
        e.default_attributes(opts[:default_attributes])
        e.save
        e
      end

      def create_role(name, run_list)
        role = Chef::Role.new
        role.name(name)
        Array(run_list).each do |item|
          role.run_list << item
        end
        role.save
        role
      end
    end
  end
end
