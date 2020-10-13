module Avo
  class App
    @@app = {
      root_path: '',
      tools: [],
      tool_classes: [],
      resources: [],
      field_names: {},
    }

    @@scripts = {}

    class << self
      def init
        puts 'Avo::App.init'.inspect
        @@app[:root_path] = Pathname.new(File.join(__dir__, '..', '..'))
        # get_tools
        # init_tools
        init_components
        init_fields
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

      # This method will take all fields available in the Avo::Fields namespace and create a method for them.
      #
      # If the field has their `def_method` set up it will follow that convention, if not it will snake_case the name:
      #
      # Avo::Fields::TextField -> text
      # Avo::Fields::TextDateTime -> date_time
      def init_fields
        puts 'init_fields'.inspect
        Avo::Fields.constants.each do |class_name|
          next if class_name.to_s == 'Field'

          field_class = method_name = nil

          if class_name.to_s.end_with? 'Field'
            field_class = "Avo::Fields::#{class_name.to_s}".safe_constantize
            method_name = field_class.get_field_name

            next if Avo::Resources::Resource.method_defined? method_name.to_sym
          end

          if field_class.present? and method_name.present?
            load_field method_name, field_class
          end
        end
      end

      def load_field(method_name, klass)
        # puts [method_name, klass].inspect
        [Avo::Resources::Resource, Avo::Actions::Action].each do |klass_entity|
          klass_entity.define_singleton_method method_name.to_sym do |*args, &block|
            if block.present?
              field_class = klass::new(args[0], **args[1] || {}, &block)
            else
              field_class = klass::new(args[0], **args[1] || {})
            end

            klass_entity.add_field(self, field_class)
          end
        end
      end

      def init_components
        puts ['init_components', Avo::Components.constants.inspect].inspect
        Avo::Components.constants.each do |class_name|
          puts class_name.inspect
          "Avo::Components::#{class_name}::Provider".safe_constantize.boot
        end
      end

      # def load_field(method_name, klass)
      #   @@app[:field_names][method_name] = klass

      #   # Load field to concerned classes
      #   [Avo::Resources::Resource, Avo::Actions::Action].each do |klass_entity|
      #     klass_entity.define_singleton_method method_name.to_sym do |*args, &block|
      #       if block.present?
      #         field_class = klass::new(args[0], **args[1] || {}, &block)
      #       else
      #         field_class = klass::new(args[0], **args[1] || {})
      #       end

      #       klass_entity.add_field(self, field_class)
      #     end
      #   end
      # end

      def get_field_names
        @@app[:field_names]
      end

      def init_resources
        @@app[:resources] = Avo::Resources.constants.select { |r| r != :Resource }.map do |c|
          if Avo::Resources.const_get(c).is_a? Class
            "Avo::Resources::#{c}".safe_constantize.new
          end
        end
      end

      def get_resources
        @@app[:resources]
      end

      def get_resource(resource)
        @@app[:resources].find do |available_resource|
          "Avo::Resources::#{resource}".safe_constantize == available_resource.class
        end
      end

      # This returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_name('user') => Avo::Resources::User
      def get_resource_by_name(name)
        self.get_resource name.singularize.camelize
      end

      # This returns the Rails model class by singular snake_cased name
      #
      # get_model_class_by_name('user') => User
      def get_model_class_by_name(name)
        name.to_s.camelize.singularize
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
        App.get_resources.map { |resource| { label: resource.resource_name_plural.humanize, resource_name: resource.url.pluralize } }.to_json.to_s.html_safe
      end

      def initializing(&block)
        yield
      end

      def script(name, directory)
        # abort name.inspect
        @@scripts[name] = directory
      end

      def get_scripts
        @@scripts
      end

      def get_script_path(name)
        @@scripts[name]
      end

      def get_script_contents(name)
        # abort get_script_path(name).inspect
        # abort [@@scripts, name].inspect
        File.read "#{get_script_path(name)}/#{name}"
      end

      def print_scripts
        @@scripts.map { |name, path| "<script src='/avo/avo-api/scripts/#{name}'></script>" }.join("\n")
      end

      def field(name, klass)
        abort [name, klass].inspect
      end
    end
  end
end
