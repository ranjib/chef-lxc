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
        plugin = knife(Chef::Knife::DataBagFromFile, *name_args) do |config|
          if opts[:encrypted]
            config[:secret_file] = opts[:secret_file]
            config[:encrypt] = true
            Chef::Config[:knife][:secret_file] = opts[:secret_file]
          end
        end
      end

      def load_secret(secret_file = nil)
        config = chef_config
        Chef::EncryptedDataBagItem.load_secret(
          secret_file || config[:knife][:secret_file]
        )
      end

      def update_data_bag_item(data_bag_name, item_name, update_hash, opts = {})
        hash = Chef::DataBagItem.load(data_bag_name, item_name)
        if opts[:encrypted]
          secret = load_secret(opts[:secret_file])
          hash = Chef::EncryptedDataBagItem.load(data_bag_name, item_name, secret).to_hash
        end
        updated_hash = hash.merge(update_hash)
        upload_data_bag_item_from_hash(data_bag_name, updated_hash, opts)
      end

      # hash must contain an entry of the form 'id' => item_name
      def upload_data_bag_item_from_hash(data_bag_name, hash, opts = {})
        config = chef_config
        if opts[:encrypted]
          secret = load_secret(opts[:secret_file])
          hash = Chef::EncryptedDataBagItem.encrypt_data_bag_item(hash, secret)
        end
        item = Chef::DataBagItem.from_hash(hash)
        item.data_bag(data_bag_name)
        item.save
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
