# What we collect, and the rules for adding a metric, live in one place:
# https://linear.app/avo-hq/document/avo-telemetry-what-we-collect-28974df26d42
class Avo::Services::TelemetryService
  class << self
    def telemetry_info
      {
        # license_key: Avo.configuration.license_key,
        avo_version: Avo::VERSION,
        rails_version: Rails::VERSION::STRING,
        ruby_version: RUBY_VERSION,
        environment: Rails.env,
        # host: current_request&.host,
        # port: current_request&.port,
        app_name: app_name,
        install_id: install_id,
        avo_metadata: avo_metadata,
      }
    end

    def app_name
      Rails.application.class.to_s.split("::").first
    rescue
      nil
    end

    # A stable, anonymous id per install, so HQ can tell apart apps that share
    # a name or have no license key. Derived one-way from secret_key_base with
    # a salt only this uses (unrelated to Rails' cookie and encryption keys),
    # then hashed again: nothing about the secret can be recovered from it.
    def install_id
      key = Rails.application.key_generator.generate_key("avo-telemetry-install-id", 32)
      Digest::SHA256.hexdigest(key)[0, 32]
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
    rescue => error
      {structural_error: error.class.name}
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

    # Only the exception class leaves the app: cache client messages carry hosts,
    # ports and connection URLs.
    def cache_operational?
      Avo.cache_store.write("avo-test-cache", "test_value")
      Avo.cache_store.read("avo-test-cache") == "test_value"
    rescue => error
      "error: #{error.class.name}"
    ensure
      begin
        Avo.cache_store.delete("avo-test-cache")
      rescue
        nil
      end
    end

    def config_metadata
      {
        config: {
          root_path: Avo.configuration.root_path
        }
      }
    end
  end
end
