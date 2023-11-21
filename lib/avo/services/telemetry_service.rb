class Avo::Services::TelemetryService
  class << self
    def telemetry_info
      {
        # license: Avo.configuration.license,
        # license_key: Avo.configuration.license_key,
        avo_version: Avo::VERSION,
        rails_version: Rails::VERSION::STRING,
        ruby_version: RUBY_VERSION,
        environment: Rails.env,
        # ip: current_request&.ip,
        # host: current_request&.host,
        # port: current_request&.port,
        app_name: app_name,
        avo_metadata: avo_metadata,
      }
    end

    def app_name
      Rails.application.class.to_s.split("::").first
    rescue
      nil
    end

    def avo_metadata
      resources = Avo.resource_manager.all
      dashboards = Avo::Current.app.dashboard_manager.all
      field_definitions = resources.map(&:get_field_definitions)
      fields_count = field_definitions.map(&:count).sum
      fields_per_resource = sprintf("%0.01f", fields_count / (resources.count + 0.0))

      field_types = {}
      custom_fields_count = 0
      field_definitions.each do |fields|
        fields.each do |field|
          field_types[field.type] ||= 0
          field_types[field.type] += 1

          custom_fields_count += 1 if field.custom?
        end
      end

      {
        resources_count: resources.count,
        dashboards_count: dashboards.count,
        fields_count: fields_count,
        fields_per_resource: fields_per_resource,
        custom_fields_count: custom_fields_count,
        field_types: field_types,
        **other_metadata(:actions),
        **other_metadata(:filters),
        main_menu_present: Avo.configuration.main_menu.present?,
        profile_menu_present: Avo.configuration.profile_menu.present?,
        cache_store: Avo.cache_store&.class&.to_s,
        **config_metadata
      }
    # rescue => error
    #   {
    #     error: error.message
    #   }
    end

    def other_metadata(type = :actions)
      resources = Avo.resource_manager.all

      types = resources.map(&:"get_#{type}")
      type_count = types.flatten.uniq.count
      type_per_resource = sprintf("%0.01f", types.map(&:count).sum / (resources.count + 0.0))

      {
        "#{type}_count": type_count,
        "#{type}_per_resource": type_per_resource
      }
    end

    def config_metadata
      {
        config: {
          root_path: Avo.configuration.root_path,
          app_name: Avo.configuration.app_name
        }
      }
    end
  end
end
