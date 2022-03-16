module Avo
  class App
    class_attribute :resources, default: []
    class_attribute :dashboards, default: []
    class_attribute :cache_store, default: nil
    class_attribute :fields, default: []
    class_attribute :request, default: nil
    class_attribute :context, default: nil
    class_attribute :license, default: nil
    class_attribute :current_user, default: nil
    class_attribute :root_path, default: nil
    class_attribute :view_context, default: nil

    class << self
      def boot
        init_fields

        I18n.locale = Avo.configuration.language_code

        if Rails.cache.instance_of?(ActiveSupport::Cache::NullStore)
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new
        else
          self.cache_store = Rails.cache
        end
      end

      def init(request:, context:, current_user:, root_path:, view_context:)
        self.request = request
        self.context = context
        self.current_user = current_user
        self.root_path = root_path
        self.view_context = view_context

        self.license = Licensing::LicenseManager.new(Licensing::HQ.new(request).response).license

        # Set the current host for ActiveStorage
        begin
          if Rails::VERSION::MAJOR === 6
            ActiveStorage::Current.host = request.base_url
          elsif Rails::VERSION::MAJOR === 7
            ActiveStorage::Current.url_options = request.base_url
          end
        rescue => exception
          Rails.logger.debug "[Avo] Failed to set ActiveStorage::Current.url_options, #{exception.inspect}"
        end

        init_resources
        init_dashboards if license.has_with_trial(:dashboards)
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
        self.resources = BaseResource.descendants
          .select do |resource|
            resource != BaseResource
          end
          .map do |resource|
            if resource.is_a? Class
              resource.new
            end
          end
      end

      def init_dashboards
        self.dashboards = Dashboards::BaseDashboard.descendants
          .select do |dashboard|
            dashboard != Dashboards::BaseDashboard
          end
      end

      # Returns the Avo dashboard by id
      def get_dashboard_by_id(id)
        dashboards.find do |dashboard|
          dashboard.id == id
        end
      end

      # Returns the Avo resource by camelized name
      #
      # get_resource_by_name('User') => UserResource
      def get_resource(resource)
        resources.find do |available_resource|
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
        resources.find do |resource|
          resource.model_class.model_name.name == name.to_s
        end
      end

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_controller_name('delayed_backend_active_record_jobs') => DelayedJobResource
      # get_resource_by_controller_name('users') => UserResource
      def get_resource_by_controller_name(name)
        resources.find do |resource|
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
        resources.select do |resource|
          Services::AuthorizationService.authorize user, resource.model_class, Avo.configuration.authorization_methods.stringify_keys["index"], raise_exception: false
        end
          .sort_by { |r| r.name }
      end

      def get_available_dashboards(user = nil)
        dashboards.sort_by { |r| r.name }
      end

      def resources_navigation(user = nil)
        get_available_resources(user)
          .select do |resource|
            resource.model_class.present?
          end
          .select do |resource|
            resource.visible_on_sidebar
          end
      end

      def get_dashboards(user = nil)
        return [] unless App.license.has_with_trial(:resource_ordering)

        get_available_dashboards(user)
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
            # remove the extension
            filename.gsub!(".html.erb", "")
            filename
          end
      end
    end
  end
end
