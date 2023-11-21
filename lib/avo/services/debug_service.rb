class Avo::Services::DebugService
  class << self
    def debug_report(request = nil)
      payload = {}

      hq = Avo::Licensing::HQ.new(request)

      payload[:license_id] = Avo::Current&.license&.id
      payload[:license_valid] = Avo::Current&.license&.valid?
      payload[:license_payload] = Avo::Current&.license&.payload
      payload[:license_response] = Avo::Current&.license&.response
      payload[:hq_payload] = hq&.payload
      payload[:thread_count] = get_thread_count
      payload[:license_abilities] = Avo::Current&.license&.abilities
      payload[:cache_store] = Avo.cache_store&.class&.to_s
      payload[:avo_metadata] = avo_metadata
      payload[:app_timezone] = Time.current.zone
      payload[:cache_key] = Avo::Licensing::HQ.cache_key
      payload[:cache_key_contents] = hq&.cached_response
      payload[:plugins] = Avo.plugin_manager

      payload
    rescue => e
      e
    end

    def get_thread_count
      Thread.list.count { |thread| thread.status == "run" }
    rescue => e
      e
    end

    def avo_metadata
      resources = Avo.resource_manager.all
      dashboards = defined?(Avo::Dashboards) ? Avo::Dashboards.dashboard_manager.all : []
      # field_definitions = resources.map(&:get_field_definitions)
      # fields_count = field_definitions.map(&:count).sum
      # fields_per_resource = sprintf("%0.01f", fields_count / (resources.count + 0.0))

      # field_types = {}
      # custom_fields_count = 0
      # field_definitions.each do |fields|
      #   fields.each do |field|
      #     field_types[field.type] ||= 0
      #     field_types[field.type] += 1

      #     custom_fields_count += 1 if field.custom?
      #   end
      # end

      {
        resources_count: resources.count,
        dashboards_count: dashboards.count,
        # fields_count: fields_count,
        # fields_per_resource: fields_per_resource,
        # custom_fields_count: custom_fields_count,
        # field_types: field_types,
        # **other_metadata(:actions), # TODO: this is fetching actions without hydration
        # **other_metadata(:filters),
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
