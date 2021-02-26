require_relative 'tools_manager'
require_relative 'filter'
require_relative 'filters/select_filter'
require_relative 'filters/boolean_filter'
require_relative 'resource'
require_relative 'tool'
require_relative 'services/authorization_service'

module Avo
  class App
    @@app = {
      root_path: '',
      resources: [],
      cache_store: nil
    }
    @@license = nil
    @@fields = []

    class << self
      def boot
        # init_controllers
        @@app[:root_path] = Pathname.new(File.join(__dir__, '..', '..'))
        init_fields
        I18n.locale = Avo.configuration.language_code

        if Rails.cache.class == ActiveSupport::Cache::NullStore
          @@app[:cache_store] ||= ActiveSupport::Cache::MemoryStore.new
        else
          @@app[:cache_store] = Rails.cache
        end
      end

      def init(current_request = nil)
        # Set the current host for ActiveStorage
        ActiveStorage::Current.host = current_request.base_url

        init_resources current_request
        @@license = LicenseManager.new(HQ.new(current_request).response).license
      end

      def app
        @@app
      end

      def fields
        @@fields
      end

      def license
        @@license
      end

      def cache_store
        @@app[:cache_store]
      end

      # This method will find all fields available in the Avo::Fields namespace and add them to a @@fields array
      # so later we can instantiate them on our resources.
      #
      # If the field has their `def_method` set up it will follow that convention, if not it will snake_case the name:
      #
      # Avo::Fields::TextField -> text
      # Avo::Fields::DateTimeField -> date_time
      def init_fields
        Avo::Fields.constants.each do |class_name|
          next if class_name.to_s == 'Field'

          field_class = method_name = nil

          if class_name.to_s.end_with? 'Field'
            field_class = "Avo::Fields::#{class_name.to_s}".safe_constantize
            method_name = field_class.get_field_name
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
        @@fields.push(
          name: method_name,
          class: klass,
        )
      end

      def init_resources(request)
        @@app[:resources] = Avo::Resources.constants
          .select do |r|
            r != :Resource
          end
          .map do |c|
            if Avo::Resources.const_get(c).is_a? Class
              "Avo::Resources::#{c}".safe_constantize.new request
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

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_name('user') => Avo::Resources::User
      def get_resource_by_name(name)
        self.get_resource name.singularize.camelize
      end

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_name('User') => Avo::Resources::User
      # get_resource_by_name(User) => Avo::Resources::User
      def get_resource_by_model_name(name)
        get_resources.find do |resource|
          resource.model_class.model_name.name == name.to_s
        end
      end

      # Returns the Rails model class by singular snake_cased name
      #
      # get_model_class_by_name('user') => User
      def get_model_class_by_name(name)
        name.to_s.camelize.singularize
      end

      def get_available_resources(user = nil)
        App.get_resources
          .select do |resource|
            AuthorizationService::authorize user, resource.model, Avo.configuration.authorization_methods.stringify_keys['index'], raise_exception: false
          end
          .sort_by { |r| r.name }
      end

      def get_navigation_items(user = nil)
        get_available_resources(user).select do |resource|
          resource.model_class.present?
        end
      end

      def draw_routes
        Proc.new do
          Avo::Resources.constants
            .select do |r|
              r != :Resource
            end
            .map do |r|
              if Avo::Resources.const_get(r).is_a? Class
                resources r.to_s.underscore.downcase.pluralize.to_sym
              end
            end
        end
      end
    end
  end
end
