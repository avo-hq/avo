require "net/http"

module Avo
  module Services
    # Installed Avo gems compared with what HQ has released. One request covers every gem, so a status page
    # with thirty plugins costs one HTTP call an hour, not thirty.
    class GemVersions
      HOST = "https://avohq.io".freeze unless const_defined?(:HOST)
      TIMEOUT = 3 unless const_defined?(:TIMEOUT) # seconds
      CACHE_TIME = 1.hour unless const_defined?(:CACHE_TIME)

      class << self
        def installed
          Avo.plugin_manager.plugins
            .filter_map { |plugin| [plugin.gem_name, plugin.version.to_s] if plugin.gem_name.present? }
            .to_h
            .merge("avo" => Avo::VERSION)
        end

        # {"avo" => "4.3.9", ...}, or {} when HQ can't be reached.
        def latest
          Avo.cache_store.fetch("avo.gem_versions.latest", expires_in: CACHE_TIME, skip_nil: true) do
            fetch("/gems.json")&.dig("gems")&.to_h { |gem| [gem["name"], gem["version"]] }
          end || {}
        end

        def latest?(gem_name, version)
          latest_version = latest[gem_name]
          latest_version.blank? || Gem::Version.new(version) >= Gem::Version.new(latest_version)
        rescue ArgumentError
          true
        end

        # Every release newer than the given {gem => version}, oldest first. [] when HQ can't be reached.
        def releases_since(versions)
          query = versions.map { |gem_name, version| ["gems[#{gem_name}]", version] }.sort

          Avo.cache_store.fetch("avo.gem_versions.releases.#{Digest::SHA256.hexdigest(query.to_s)}", expires_in: CACHE_TIME, skip_nil: true) do
            fetch("/releases.json", query)&.dig("releases")
          end || []
        end

        private

        def fetch(path, query = [])
          uri = URI("#{HOST}#{path}")
          uri.query = URI.encode_www_form(query) if query.any?

          response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: TIMEOUT, read_timeout: TIMEOUT) do |http|
            http.get(uri.request_uri, "Accept" => "application/json")
          end

          JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
        rescue => error
          Rails.logger.warn "[Avo->] Could not fetch #{path} from HQ: #{error.class}"
          nil
        end
      end
    end
  end
end
