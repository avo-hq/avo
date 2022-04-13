require 'docile'
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
    class_attribute :params, default: {}
    class_attribute :translation_enabled, default: false

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

      def init(request:, context:, current_user:, root_path:, view_context:, params:)
        self.request = request
        self.context = context
        self.current_user = current_user
        self.root_path = root_path
        self.view_context = view_context
        self.params = params

        self.license = Licensing::LicenseManager.new(Licensing::HQ.new(request).response).license
        self.translation_enabled = license.has(:localization)

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
            # Remove the BaseResource. We only need the descendants
            resource != BaseResource
          end
          .uniq do |klass|
            # On invalid resource configuration the resource classes get duplicated in `ObjectSpace`
            # We need to de-duplicate them
            klass.name
          end
          .map do |resource|
            resource.new if resource.is_a? Class
          end
      end

      def init_dashboards
        self.dashboards = Dashboards::BaseDashboard.descendants
          .select do |dashboard|
            dashboard != Dashboards::BaseDashboard
          end
          .uniq do |dashboard|
            dashboard.id
          end
      end

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

      def menu_parse(parser, &block)
        Docile.dsl_eval(parser, &block).build
      end

      def menu
        menu_parse MenuBuilder.new, &Avo.configuration.menu
        # bll = -> {
        #   name 'John Smith'
        #   mother {
        #     name 'Mary Smith'
        #   }
        #   father {
        #     name 'Tom Smith'
        #     mother {
        #       name 'Jane Smith'
        #     }
        #   }
        # }



        # block
      end

    end
  end
end

require "dry-initializer"

class BaseItem
  extend Dry::Initializer

  option :name, default: proc { "" }
  option :items, default: proc { [] }
  option :collapsable, default: proc { false }
end

class ResourceItem
  extend Dry::Initializer

  option :resource

  def parsed_resource
    Avo::App.get_resource_by_name resource.to_s
  end
end

class DashboardItem
  extend Dry::Initializer

  option :dashboard

  def parsed_dashboard
    dashboard_by_id || dashboard_by_name
  end

  def dashboard_by_name
    Avo::App.get_dashboard_by_name dashboard.to_s
  end

  def dashboard_by_id
    Avo::App.get_dashboard_by_id dashboard.to_s
  end
end

class MenuItem < BaseItem
  option :path, default: proc { "" }
  option :target, optional: true
end

class SectionItem < BaseItem
  option :icon, optional: true
end

class GroupItem < BaseItem
end

Menu = Struct.new(:name, :items)
class MenuBuilder
  def initialize(name: nil, items: [])
    @menu = Menu.new

    # @menu.sections = []
    # @menu.groups = []
    @menu.name = name
    @menu.items = items
  end

  def item(name, **args)
    @menu.items << MenuItem.new(name: name, **args)
  end

  def resource(resource)
    @menu.items << ResourceItem.new(resource: resource)
  end

  def dashboard(dashboard)
    @menu.items << DashboardItem.new(dashboard: dashboard)
  end

  def section(name, **args, &block)
    # abort args.inspect
    @menu.items << SectionItem.new(name: name, **args, items: Avo::App.menu_parse(MenuBuilder.new, &block).items)
  end

  def group(name, **args, &block)
    @menu.items << GroupItem.new(name: name, **args, items: Avo::App.menu_parse(MenuBuilder.new, &block).items)
  end

  def rest_of_resources

  end

  def rest_of_dashboards

  end

  def rest_of_tools

  end

  def build
    @menu
  end
end

# class SectionBuilder
#   def initialize(name: nil, items: [])
#     @menu = Menu.new
#     puts ["name->", self, name].inspect

#     @menu.items = items
#   end
#   def item(name)
#     # puts ["name->", name].inspect
#     @menu.items << BaseItem.new(name: name)
#   end

#   def section(name, &block)
#     parsed_section = Avo::App.menu_parse(&block)
#     # abort parsed_section.inspect
#     # abort name.inspect
#     @menu.items << BaseItem.new(name: name, items: parsed_section.items)
#   end

#   def build
#     @menu
#   end
# end

