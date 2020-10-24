require_relative 'tools_manager'
require_relative 'filter'
require_relative 'filters/select_filter'
require_relative 'filters/boolean_filter'
require_relative 'resource'
require_relative 'tool'
require_relative 'authorization_service'

module Avo
  class App
    @@app = {
      root_path: '',
      resources: [],
      field_names: {},
    }
    @@license = nil

    class << self
      def boot
        @@app[:root_path] = Pathname.new(File.join(__dir__, '..', '..'))
        init_fields
      end

      def init(current_request = nil)
        init_resources
        @@license = LicenseManager.new(HQ.new(current_request).response).license
      end

      def app
        @@app
      end

      def license
        @@license
      end

      # This method will take all fields available in the Avo::Fields namespace and create a method for them.
      #
      # If the field has their `def_method` set up it will follow that convention, if not it will snake_case the name:
      #
      # Avo::Fields::TextField -> text
      # Avo::Fields::TextDateTime -> date_time
      def init_fields
        Avo::Fields.constants.each do |class_name|
          next if class_name.to_s == 'Field'

          field_class = method_name = nil

          if class_name.to_s.end_with? 'Field'
            field_class = "Avo::Fields::#{class_name.to_s}".safe_constantize
            method_name = field_class.get_field_name

            next if Avo::Resources::Resource.method_defined? method_name.to_sym
          else
            # Try one level deeper for custom fields
            namespace = class_name
            tool_provider = "Avo::Fields::#{namespace}::ToolProvider".safe_constantize

            next unless tool_provider.present?

            tool_provider.boot

            "Avo::Fields::#{namespace}".safe_constantize.constants.each do |custom_field_class|
              next unless custom_field_class.to_s.end_with? 'Field' or custom_field_class.to_s == 'Field'

              field_class = "Avo::Fields::#{namespace}::#{custom_field_class}".safe_constantize
              method_name = field_class.get_field_name
            end
          end

          if field_class.present? and method_name.present?
            load_field method_name, field_class
          end
        end
      end

      def load_field(method_name, klass)
        @@app[:field_names][method_name] = klass

        # Load field to concerned classes
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

      def get_resources_navigation(user)
        App.get_resources
          .select { |resource| AuthorizationService::authorize user, resource.model, 'index?' }
          .map { |resource| { label: resource.resource_name_plural.humanize, resource_name: resource.url.pluralize } }
          .reject { |i| i.blank? }
          .to_json
          .to_s
          .html_safe
      end
    end
  end
end
