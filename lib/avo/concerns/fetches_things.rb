module Avo
  module Concerns
    module FetchesThings
      extend ActiveSupport::Concern

      class_methods do
        # Returns the Avo dashboard by id
        #
        # get_dashboard_by_id(:dashy) -> Dashy
        def get_dashboard_by_id(id)
          dashboards.find do |dashboard|
            dashboard.id == id
          end
        end

        # Returns the Avo dashboard by name
        #
        # get_dashboard_by_name(:dashy) -> Dashy
        def get_dashboard_by_name(name)
          dashboards.find do |dashboard|
            dashboard.name == name
          end
        end

        # Returns the Avo resource by camelized name
        #
        # get_resource_by_name('User') => UserResource
        def get_resource(resource)
          possible_resource = "#{resource}Resource".gsub "ResourceResource", "Resource"

          resources.find do |available_resource|
            possible_resource.safe_constantize == available_resource.class
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

        # Returns the Avo resource by some name
        def guess_resource(name)
          get_resource_by_name(name.to_s) || get_resource_by_model_name(name)
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

        def resources_for_navigation(user = nil)
          get_available_resources(current_user)
            .select do |resource|
              resource.model_class.present?
            end
            .select do |resource|
              resource.visible_on_sidebar
            end
        end

        def dashboards_for_navigation(user = nil)
          return [] if App.license.lacks_with_trial(:resource_ordering)

          get_available_dashboards(user).select do |dashboard|
            dashboard.is_visible?
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
              # remove the extension
              filename.gsub!(".html.erb", "")
              filename
            end
        end

        def tools_for_navigation
          return [] if Avo::App.license.lacks_with_trial(:custom_tools)

          get_sidebar_partials
        end
      end
    end
  end
end
