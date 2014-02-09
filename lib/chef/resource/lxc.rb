require 'chef/resource'

class Chef
  class Resource
    class Container < Chef::Resource

      identity_attr :container_name

      def initialize(name, run_context = nil)
        super
        @resource_name = :container
        @container_name = name
        @options = {}
        @provider = Chef::Provider::Container
        @action = :create
        @allowed_actions += [:start, :stop, :destroy, :create]
      end

      def container_name(arg = nil)
        set_or_return(:container_name, arg, kind_of: [ String ] )
      end

      def options(arg = nil)
        set_or_return(:options, arg, kind_of: [ Hash ] )
      end
    end
  end
end
