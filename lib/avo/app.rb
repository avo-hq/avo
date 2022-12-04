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
    class_attribute :error_messages

    class << self
      def eager_load(entity)
        paths = Avo::ENTITIES.fetch entity

        return unless paths.present?

        pathname = Rails.root.join(*paths)
        if pathname.directory?
          Rails.autoloaders.main.eager_load_dir(pathname.to_s)
        end
      end

      def boot
        init_fields

        if Rails.cache.instance_of?(ActiveSupport::Cache::NullStore)
          self.cache_store ||= ActiveSupport::Cache::MemoryStore.new
        else
          self.cache_store = Rails.cache
        end
      end

      # Renerate a dynamic root path using the URIService
      def root_path(paths: [], query: {}, **args)
        Avo::Services::URIService.parse(view_context.avo.root_url.to_s)
          .append_paths(paths)
          .append_query(query)
          .to_s
      end

      def init(request:, context:, current_user:, view_context:, params:)
        self.error_messages = []
        self.context = context
        self.current_user = current_user
        self.params = params
        self.request = request
        self.view_context = view_context

        self.license = Licensing::LicenseManager.new(Licensing::HQ.new(request).response).license
        self.translation_enabled = license.has(:localization)

        # Set the current host for ActiveStorage
        begin
          if defined?(ActiveStorage::Current)
            if Rails::VERSION::MAJOR === 6
              ActiveStorage::Current.host = request.base_url
            elsif Rails::VERSION::MAJOR === 7
              ActiveStorage::Current.url_options = request.base_url
            end
          end
        rescue => exception
          Rails.logger.debug "[Avo] Failed to set ActiveStorage::Current.url_options, #{exception.inspect}"
        end

        check_bad_resources
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

      def check_bad_resources
        resources.each do |resource|
          has_model = resource.model_class.present?

          unless has_model
            possible_model = resource.class.to_s.gsub "Resource", ""

            Avo::App.error_messages.push({
              url: "https://docs.avohq.io/2.0/resources.html#custom-model-class",
              target: "_blank",
              message: "#{resource.class.to_s} does not have a valid model assigned. It failed to find the #{possible_model} model. \n\r Please create that model or assign one using self.model_class = YOUR_MODEL"
            })
          end
        end
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
        eager_load :dashboards unless Rails.application.config.eager_load

        self.dashboards = Dashboards::BaseDashboard.descendants
          .select do |dashboard|
            dashboard != Dashboards::BaseDashboard
          end
          .uniq do |dashboard|
            dashboard.id
          end
      end

      def has_main_menu?
        return false if Avo::App.license.lacks_with_trial(:menu_editor)
        return false if Avo.configuration.main_menu.nil?

        true
      end

      def has_profile_menu?
        return false if Avo::App.license.lacks_with_trial(:menu_editor)
        return false if Avo.configuration.profile_menu.nil?

        true
      end

      def main_menu
        # Return empty menu if the app doesn't have the profile menu configured
        return Avo::Menu::Builder.new.build unless has_main_menu?

        Avo::Menu::Builder.parse_menu(&Avo.configuration.main_menu)
      end

      def profile_menu
        # Return empty menu if the app doesn't have the profile menu configured
        return Avo::Menu::Builder.new.build unless has_profile_menu?

        Avo::Menu::Builder.parse_menu(&Avo.configuration.profile_menu)
      end

      def debug_report(request = nil)
        payload = {}

        hq = Avo::Licensing::HQ.new(request)

        payload[:license_id] = Avo::App&.license&.id
        payload[:license_valid] = Avo::App&.license&.valid?
        payload[:license_payload] = Avo::App&.license&.payload
        payload[:license_response] = Avo::App&.license&.response
        payload[:hq_payload] = hq&.payload
        payload[:thread_count] = get_thread_count
        payload[:license_abilities] = Avo::App&.license&.abilities
        payload[:cache_store] = self.cache_store&.class&.to_s
        payload[:avo_metadata] = hq&.avo_metadata
        payload[:app_timezone] = Time.current.zone
        payload[:cache_key] = Avo::Licensing::HQ.cache_key
        payload[:cache_key_contents] = hq&.cached_response

        payload
      rescue => e
        e
      end

      def get_thread_count
        Thread.list.select {|thread| thread.status == "run"}.count
      rescue => e
        e
      end
    end
  end
end
