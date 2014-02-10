require 'chef/resource'

class Chef
  class Resource
    class Lxc < Chef::Resource

      class LXCTemplate
      end

      identity_attr :container_name

      def initialize(name, run_context = nil)
        super
        @resource_name = :container
        @container_name = name
        @options = {}
        @provider = Chef::Provider::Lxc
        @action = :create
        @allowed_actions += [:start, :stop, :destroy, :create]
      end

      def container_name(arg = nil)
        set_or_return(:container_name, arg, kind_of: [ String ] )
      end

      def options(arg = nil)
        set_or_return(:options, arg, kind_of: [ Hash ] )
      end

      def template(type, &block)
        t =  LXCTemplate.new(type)
        if block_given?
          t.instance_eval(&block)
        end
      end
    end
  end
end
