module Avo
  module Licensing
    class HQ
      attr_accessor :current_request

      ENDPOINT = "https://avohq.io/api/v1/licenses/check".freeze unless const_defined?(:ENDPOINT)
      CACHE_KEY = "avo.hq.response".freeze unless const_defined?(:CACHE_KEY)
      REQUEST_TIMEOUT = 5 unless const_defined?(:REQUEST_TIMEOUT) # seconds

      def initialize(current_request)
        @current_request = current_request
        @cache_store = Avo::App.cache_store
      end

      def response
        @hq_response || request
      end

      private

      def request
        return cached_response if has_cached_response

        begin
          perform_and_cache_request
        rescue Errno::EHOSTUNREACH => exception
          cache_and_return_error "HTTP host not reachable error.", exception.message
        rescue Errno::ECONNRESET => exception
          cache_and_return_error "HTTP connection reset error.", exception.message
        rescue Errno::ECONNREFUSED => exception
          cache_and_return_error "HTTP connection refused error.", exception.message
        rescue HTTParty::Error => exception
          cache_and_return_error "HTTP client error.", exception.message
        rescue Net::OpenTimeout => exception
          cache_and_return_error "Request timeout.", exception.message
        rescue Net::ReadTimeout => exception
          cache_and_return_error "Request timeout.", exception.message
        rescue SocketError => exception
          cache_and_return_error "Connection error.", exception.message
        end
      end

      def perform_and_cache_request
        hq_response = perform_request

        return cache_and_return_error "Avo HQ Internal server error.", hq_response.body if hq_response.code == 500

        cache_response 1.hour.to_i, hq_response.parsed_response if hq_response.code == 200
      end

      def cache_response(time, response)
        response.merge!(
          expiry: time,
          **payload
        ).stringify_keys!

        @cache_store.write(CACHE_KEY, response, expires_in: time)

        @hq_response = response

        response
      end

      def perform_request
        ::Rails.logger.debug "[Avo] Performing request to avohq.io API to check license availability." if Rails.env.development?

        HTTParty.post ENDPOINT, body: payload.to_json, headers: {'Content-type': "application/json"}, timeout: REQUEST_TIMEOUT
      end

      def payload
        {
          license: Avo.configuration.license,
          license_key: Avo.configuration.license_key,
          avo_version: Avo::VERSION,
          rails_version: Rails::VERSION::STRING,
          ruby_version: RUBY_VERSION,
          environment: Rails.env,
          ip: current_request.ip,
          host: current_request.host,
          port: current_request.port,
          app_name: app_name
        }
      end

      def app_name
        Rails.application.class.to_s.split("::").first
      rescue
        nil
      end

      def avo_metadata
        resources = App.resources
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
          fields_count: fields_count,
          fields_per_resource: fields_per_resource,
          custom_fields_count: custom_fields_count,
          field_types: field_types,
          **other_metadata(:actions),
          **other_metadata(:filters),
        }
      end

      def other_metadata(type = :actions)
        resources = App.resources

        types = resources.map(&:"get_#{type}")
        type_count = types.flatten.uniq.count
        type_per_resource = sprintf("%0.01f", types.map(&:count).sum / (resources.count + 0.0))

        {
          "#{type}_count": type_count,
          "#{type}_per_resource": type_per_resource,
        }
      end

      def cache_and_return_error(error, exception_message = "")
        cache_response 5.minutes.to_i, {error: error, exception_message: exception_message}.stringify_keys
      end

      def has_cached_response
        @cache_store.exist? CACHE_KEY
      end

      def cached_response
        @cache_store.read CACHE_KEY
      end
    end
  end
end
