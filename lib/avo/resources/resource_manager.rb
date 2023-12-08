module Avo
  module Resources
    class ResourceManager
      attr_accessor :resources

      alias_method :all, :resources

      class << self
        def build
          instance = new
          instance.check_bad_resources
          instance
        end

        # Fetches the resources available to the application.
        # We have two ways of doing that.
        #
        # 1. Through eager loading.
        # We automatically eager load the resources directory and fetch the descendants from the scanned files.
        # This is the simple way to get started.
        #
        # 2. Manually, declared by the user.
        # We have this option to load the resources because when they are loaded automatically through eager loading,
        # those Resource classes and their methods may trigger loading other classes. And that may disrupt Rails booting process.
        # Ex: AdminResource may use self.model_class = User. That will trigger Ruby to load the User class and itself load
        # other classes in a chain reaction.
        # The scenario that comes up most often is when Rails boots, the routes are being computed which eager loads the resource files.
        # At that boot time some migration might have not been run yet, but Rails tries to access them through model associations,
        # and they are not available.
        #
        # To enable this feature add a `resources` array config in your Avo initializer.
        # config.resources = [
        #   "UserResource",
        #   "FishResource",
        # ]
        def fetch_resources
          if Avo.configuration.resources.present?
            load_configured_resources
          else
            load_resources_namespace
          end

          BaseResource.descendants
        end

        def load_resources_namespace
          Rails.autoloaders.main.eager_load_namespace(Avo::Resources)
        end

        def load_configured_resources
          raise 'Resources configuration must be an array' unless Avo.configuration.resources.is_a? Array

          Avo.configuration.resources.each do |resource|
            resource.to_s.safe_constantize
          end
        end
      end

      def initialize
        @resources = self.class.fetch_resources
      end

      def check_bad_resources
        resources.each do |resource|
          has_model = resource.model_class.present?

          unless has_model
            possible_model = resource.to_s.gsub "Avo::Resources::", ""
            possible_model = possible_model.gsub "Resource", ""

            Avo.error_manager.add({
              url: "https://docs.avohq.io/2.0/resources.html#custom-model-class",
              target: "_blank",
              message: "#{resource} does not have a valid model assigned. It failed to find the #{possible_model} model. \n\r Please create that model or assign one using self.model_class = YOUR_MODEL"
            })
          end
        end
      end

      # Filters out the resources that are missing the model_class
      def valid_resources
        resources.select { |resource| resource.model_class.present? }.sort_by(&:name)
      end

      # Returns the Avo resource by camelized name
      #
      # get_resource_by_name('User') => instance of Avo::Resources::User
      def get_resource(resource)
        resource = "Avo::Resources::#{resource}" unless resource.to_s.starts_with?("Avo::Resources::")

        resources.find do |available_resource|
          resource.to_s == available_resource.to_s
        end
      end

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_name('user') => instance of Avo::Resources::User
      def get_resource_by_name(name)
        get_resource name.singularize.camelize
      end

      # Returns the Avo resource by singular snake_cased name
      # From all the resources that use the same model_class, it will fetch the first one in alphabetical order
      #
      # get_resource_by_name('User') => instance of Avo::Resources::User
      # get_resource_by_name(User) => instance of Avo::Resources::User

      def get_resource_by_model_class(klass)
        # Fetch the mappings imposed by the user.
        # If they are present, use those ones.
        mapping = get_mapping_for_model klass
        return get_resource(mapping) if mapping.present?

        valid_resources
          .find do |resource|
            resource.model_class.model_name.name == klass.to_s
          end
      end

      # Returns the Avo resource by singular snake_cased name
      #
      # get_resource_by_controller_name('delayed_backend_active_record_jobs') => instance of Avo::Resources::DelayedJob
      # get_resource_by_controller_name('users') => instance of Avo::Resources::User
      def get_resource_by_controller_name(name)
        valid_resources
          .find do |resource|
            resource.model_class.to_s.pluralize.underscore.tr("/", "_") == name.to_s
          end
      end

      # Returns the Avo resource by some name
      def guess_resource(name)
        get_resource_by_name(name.to_s) || get_resource_by_model_class(name)
      end

      # Returns the Rails model class by singular snake_cased name
      #
      # get_model_class_by_name('user') => User
      def get_model_class_by_name(name)
        name.to_s.camelize.singularize
      end

      def get_available_resources(user = nil)
        valid_resources
          .select do |resource|
            resource.authorization.class.authorize(
              user,
              resource.model_class,
              Avo.configuration.authorization_methods.stringify_keys["index"],
              raise_exception: false
            )
          end
          .sort_by { |r| r.name }
      end

      def resources_for_navigation(user = nil)
        get_available_resources(user)
          .select do |resource|
            resource.visible_on_sidebar
          end
      end

      private

      def get_mapping_for_model(klass)
        (Avo.configuration.model_resource_mapping || {}).stringify_keys.transform_values(&:to_s)[klass.to_s]
      end
    end
  end
end
