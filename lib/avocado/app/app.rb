
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

      # This method will take all fields available in the Avocado::Fields namespace and create a method for them.
      #
      # If the field has their `def_method` set up it will folow that convention, if not it will snake_case the name:
      #
      # Avocado::Fields::TextField -> text
      # Avocado::Fields::TextDateTime -> date_time
      def init_fields
        field_class = nil
        # if class_name.to_s === 'CustomFields'
          Avocado::CustomFields.constants.each do |namespace|
            "Avocado::CustomFields::#{namespace}".safe_constantize.constants.each do |custom_field_class|
              next unless custom_field_class.to_s.end_with? 'Field' or custom_field_class.to_s == 'Field'

              field_class = "Avocado::CustomFields::#{namespace}::#{custom_field_class}".safe_constantize
              method_name = field_class.get_def_name

              load_field method_name, field_class

              puts "guessed class #{field_class}".inspect
            end
          end
        # end

        Avocado::Fields.constants.each do |class_name|
          next unless class_name.to_s.end_with? 'Field' or class_name.to_s == 'Field'

          # puts class_name.to_s.inspect
          puts "Avocado::Fields::#{class_name.to_s}".inspect
          # abort possible_class.inspect
          field_class = "Avocado::Fields::#{class_name.to_s}".safe_constantize
          method_name = field_class.get_def_name

          next if Avocado::Resources::Resource.method_defined? method_name.to_sym

          load_field method_name, field_class
        end
      end

      def load_field(method_name, klass)
        Avocado::Resources::Resource::define_singleton_method method_name.to_sym do |*args, &block|
          puts "1---> #{klass.to_s}".inspect
          if block.present?
            field_class = klass::new(args[0], **args[1] || {}, &block)
          else
            field_class = klass::new(args[0], **args[1] || {})
          end

          puts "2---> #{field_class.to_s}".inspect

          Avocado::Resources::Resource.add_field(self, field_class)
        end
      end

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
        @@app[:resources].find do |available_resource|
          "Avocado::Resources::#{resource}".safe_constantize == available_resource.class
        end
      end

      # This returns the Avocado resource by singular snake_cased name
      #
      # get_resource_by_name('user') => Avocado::Resources::User
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
    end
  end
end
