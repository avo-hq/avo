module Avo
  class App
    include Avo::Concerns::FetchesThings

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

      def main_menu
        return nil if Avo::App.license.lacks_with_trial(:menu_builder)

        Avo::Menu::Builder.parse_menu(&Avo.configuration.main_menu)
      end

      def profile_menu
        return nil if Avo::App.license.lacks_with_trial(:menu_builder)

        Avo::Menu::Builder.parse_menu(&Avo.configuration.profile_menu)
      end
    end
  end
end
