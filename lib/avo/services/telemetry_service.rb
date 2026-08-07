class Avo::Services::TelemetryService
  class << self
    def telemetry_info
      {
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

    # The structural counts (resources, fields, field types, actions, filters)
    # are gathered statically with Prism — no boot, no resource instantiation,
    # no user code. The runtime-only values (menus, cache, config) are read
    # here, where the live objects are already on hand.
    def avo_metadata
      structural_metadata.merge(runtime_metadata)
    end

    def structural_metadata
      StaticCollector.new(Rails.root).collect
    end

    def runtime_metadata
      {
        main_menu_present: Avo.configuration.main_menu.present?,
        profile_menu_present: Avo.configuration.profile_menu.present?,
        cache_store: Avo.cache_store&.class&.to_s,
        cache_operational: cache_operational?,
        plugins: plugins_metadata,
        **config_metadata
      }
    end

    # The Avo ecosystem gems actually registered with the plugin manager (a
    # subset of installed gems — only those that booted), with their resolved
    # gem name and version.
    def plugins_metadata
      Avo.plugin_manager.all.map do |plugin|
        {
          name: plugin.gem_name || plugin.name.to_s,
          version: plugin.version
        }
      end
    rescue
      []
    end

    def cache_operational?
      Avo.cache_store.write("avo-test-cache", "test_value")
      operational = Avo.cache_store.read("avo-test-cache") == "test_value"
      Avo.cache_store.delete("avo-test-cache")
      operational
    rescue => error
      "error: #{error.message}"
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
