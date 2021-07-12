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
          port: current_request.port
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
