module Avo
  class App
    class_attribute :app, default: {
      resources: [],
      cache_store: nil
    }
    class_attribute :fields, default: []
    class_attribute :request, default: nil
    class_attribute :context, default: nil
    class_attribute :license, default: nil

    class << self
      def boot
        init_fields

        I18n.locale = Avo.configuration.language_code

        if Rails.cache.instance_of?(ActiveSupport::Cache::NullStore)
          app[:cache_store] ||= ActiveSupport::Cache::MemoryStore.new
        else
          app[:cache_store] = Rails.cache
        end
      end

      def init(request:, context:)
        self.request = request
        self.context = context

        # Set the current host for ActiveStorage
        ActiveStorage::Current.host = request.base_url

        init_resources

        self.license = Licensing::LicenseManager.new(Licensing::HQ.new(request).response).license
      end

      def cache_store
        app[:cache_store]
      end

      # This method will find all fields available in the Avo::Fields namespace and add them to the fields class_variable array
      # so later we can instantiate them on our resources.
      #
      # If the field has their `def_method` set up it will follow that convention, if not it will snake_case the name:
      #
      # Avo::Fields::TextField -> text
      # Avo::Fields::DateTimeField -> date_time
      def init_fields
        Avo::Fields::BaseField.descendants.each do |class_name|
          next if class_name.to_s == "BaseField"

          if class_name.to_s.end_with? "Field"
            load_field class_name.get_field_name, class_name
          end
        end
      end

      def load_field(method_name, klass)
        fields.push(
          name: method_name,
          class: klass
        )
      end

      def init_resources
        app[:resources] = BaseResource.descendants
          .select do |resource|
            resource != BaseResource
          end
          .map do |resource|
            if resource.is_a? Class
              resource.new
            end
          end
      end

      def get_resources
        app[:resources]
      end

      # Returns the Avo resource by camelized name
      #
      # get_resource_by_name('User') => UserResource
      def get_resource(resource)
        app[:resources].find do |available_resource|
          "#{resource}Resource".safe_constantize == available_resource.class
        end
      end

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_name('user') => UserResource
      def get_resource_by_name(name)
        get_resource name.singularize.camelize
      end

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_name('User') => UserResource
      # get_resource_by_name(User) => UserResource
      def get_resource_by_model_name(name)
        get_resources.find do |resource|
          resource.model_class.model_name.name == name.to_s
        end
      end

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_controller_name('delayed_backend_active_record_jobs') => DelayedJobResource
      # get_resource_by_controller_name('users') => UserResource
      def get_resource_by_controller_name(name)
        get_resources.find do |resource|
          resource.model_class.to_s.pluralize.underscore.tr("/", "_") == name.to_s
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
            Services::AuthorizationService.authorize user, resource.model, Avo.configuration.authorization_methods.stringify_keys["index"], raise_exception: false
          end
          .sort_by { |r| r.name }
      end

      def resources_navigation(user = nil)
        get_available_resources(user).select do |resource|
          resource.model_class.present?
        end
      end

      # Insert any partials that we find in app/views/avo/sidebar/items.
      def get_sidebar_partials
        Dir.glob(Rails.root.join("app", "views", "avo", "sidebar", "items", "*.html.erb"))
          .map do |path|
            File.basename path
          end
          .map do |filename|
            # remove the leading underscore (_)
            filename[0] = ""
            filename
          end
      end

      def draw_routes
        # We should eager load all the classes so we find all descendants
        Rails.application.eager_load!

        proc do
          BaseResource.descendants
            .select do |resource|
              resource != :BaseResource
            end
            .map do |resource|
              if resource.is_a? Class
                route_key = if resource.model_class.present?
                  resource.model_class.model_name.route_key
                else
                  resource.to_s.underscore.gsub("_resource", "").downcase.pluralize.to_sym
                end

                resources route_key
              end
            end
        end
      end
    end
  end
end
