require 'chef/resource'

class Chef
  class Resource
    class Lxc < Chef::Resource

      class InlineRecipe
      end

      class LXCTemplate
        attr_reader :type, :bd, :options
        def initialize(type='ubuntu')
          @type = type
          @bd = nil
          @options = []
        end

        def args(args)
          @options = args
        end

        def block_device(bd)
          @bd = bd
        end
      end

      identity_attr :container_name
      attr_reader :lxc_template, :recipe_block

      def initialize(name, run_context = nil)
        super
        @resource_name = :container
        @container_name = name
        @provider = Chef::Provider::Lxc
        @action = :create
        @allowed_actions += [:start, :stop, :destroy, :create]
        @lxc_template = LXCTemplate.new
        @recipe_block = nil
      end

      def container_name(arg = nil)
        set_or_return(:container_name, arg, kind_of: [ String ] )
      end

      def template(type = 'ubuntu', &block)
        @lxc_template = LXCTemplate.new(type)
        if block_given?
          @lxc_template.instance_eval(&block)
        end
      end

      def recipe(&block)
        @recipe_block = block
      end
    end
  end
end
