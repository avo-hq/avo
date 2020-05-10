require_relative 'tools_manager'
require_relative 'filter'
require_relative 'resource'
require_relative 'tool'

module Avocado
  class App
    @@app = {
      root_path: '',
      tools: [],
      tool_classes: [],
      resources: [],
    }

    class << self
      def init
        @@app[:root_path] = Pathname.new(File.join(__dir__, '..', '..'))
        # get_tools
        # init_tools
        init_resources
      end

      def app
        @@app
      end

      # def tools
      #   @@app[:tools]
      # end

      # def get_tools
      #   @@app[:tool_classes] = ToolsManager.get_tools
      # end

      def init_resources
        @@app[:resources] = Avocado::Resources.constants.select { |r| r != :Resource }.map do |c|
          if Avocado::Resources.const_get(c).is_a? Class
            "Avocado::Resources::#{c}".safe_constantize.new
          end
        end
      end

      def get_resources
        @@app[:resources]
      end

      def get_resource(resource)
        @@app[:resources].find { |available_resource| "Avocado::Resources::#{resource}".safe_constantize == available_resource.class }
      end

      def get_resource_by_name(resource)
        self.get_resource resource.singularize.camelize
      end

      # def init_tools
      #   @@app[:tool_classes].each do |tool_class|
      #     @@app[:tools].push tool_class.new
      #   end
      # end

      # def render_navigation
      #   navigation = []
      #   @@app[:tools].each do |tool|
      #     navigation.push(tool.render_navigation) if tool.class.method_defined?(:render_navigation)
      #   end

      #   navigation.join('')
      # end

      def get_resources_navigation
        App.get_resources.map { |resource| { label: resource.name, resource_name: resource.url.pluralize }}.to_json.to_s.html_safe
      end
    end
  end
end
