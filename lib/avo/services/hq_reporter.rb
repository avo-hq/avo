require 'net/http'

module Avo
  module Services
    class HqReporter
      ENDPOINT = 'https://v3.avohq.io/api/v3/licenses/check'.freeze
      REQUEST_TIMEOUT = 5 # seconds
      CACHE_TIME = 24.hours.to_i # seconds

      class << self
        def cache_key
          "avo.hq_reporter-#{Avo::VERSION.parameterize}.reported"
        end

        # Fire and forget - call this from a thread
        # request_info should be a hash with :ip, :host, :port keys
        def report(request_info = {})
          return unless should_report?

          cache_store.write(cache_key, { reported_at: Time.now }, expires_in: CACHE_TIME)

          perform_request(request_info)
        rescue StandardError
          # Silently swallow all errors
        end

        private

        def should_report?
          # return false unless Rails.env.production?
          return false if Avo.plugin_manager.installed?('avo-licensing')
          return false if already_reported?

          true
        end

        def already_reported?
          cached = cache_store.read(cache_key)
          return false unless cached.present?

          # Handle cache stores that don't auto-expire
          reported_at = cached[:reported_at] || cached['reported_at']
          return false unless reported_at

          Time.parse(reported_at.to_s) > Time.now - CACHE_TIME
        rescue StandardError
          false
        end

        def cache_store
          Avo.configuration.cache_store
        end

        def payload(request_info)
          result = {
            license_key: Avo.configuration.license_key,
            avo_version: Avo::VERSION,
            rails_version: Rails::VERSION::STRING,
            ruby_version: RUBY_VERSION,
            environment: Rails.env,
            ip: request_info[:ip],
            host: request_info[:host],
            port: request_info[:port],
            app_name: app_name
          }

          if Avo.configuration.send_metadata
            begin
              result[:avo_metadata] = Avo::Services::TelemetryService.avo_metadata
            rescue StandardError => e
              result[:avo_metadata] = {
                error_message: e.message,
                error: 'Failed to generate the Avo metadata'
              }
            end
          else
            result[:avo_metadata] = :disabled
          end

          result
        end

        def perform_request(request_info)
          uri = URI.parse(ENDPOINT)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')
          http.read_timeout = REQUEST_TIMEOUT
          http.open_timeout = REQUEST_TIMEOUT
          request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
          request.body = payload(request_info).to_json
          http.request(request)
        end

        def app_name
          Rails.application.class.to_s.split('::').first
        rescue StandardError
          nil
        end
      end
    end
  end
end

