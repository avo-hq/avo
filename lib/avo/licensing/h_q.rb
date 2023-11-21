module Avo
  module Licensing
    class HQ
      attr_accessor :current_request
      attr_accessor :cache_store

      ENDPOINT = "https://v3.avohq.io/api/v3/licenses/check".freeze unless const_defined?(:ENDPOINT)
      REQUEST_TIMEOUT = 5 unless const_defined?(:REQUEST_TIMEOUT) # seconds
      CACHE_TIME = 6.hours.to_i unless const_defined?(:CACHE_TIME) # seconds

      class << self
        def cache_key
          "avo.hq-#{Avo::VERSION.parameterize}.response"
        end
      end

      def initialize(current_request = nil)
        @current_request = current_request
        @cache_store = Avo.cache_store
      end

      def response
        expire_cache_if_overdue

        # ------------------------------------------------------------------
        # You could set this to true to become a pro user for free.
        # I'd rather you didn't. Avo takes time & love to build,
        # and I can't do that if it doesn't pay my bills!
        #
        # If you want Pro, help pay for its development.
        # Can't afford it? Get in touch: adrian@avohq.io
        # ------------------------------------------------------------------
        make_request
      end

      # Some cache stores don't auto-expire their keys and payloads so we need to do it for them
      def expire_cache_if_overdue
        return unless cached_response.present? || cached_response&.fetch(:fetched_at, nil).present?

        parsed_time = Time.parse(cached_response["fetched_at"].to_s)
        cache_should_expire = parsed_time < Time.now - CACHE_TIME

        clear_response if cache_should_expire
      end

      def fresh_response
        clear_response

        make_request
      end

      def clear_response
        cache_store.delete self.class.cache_key
      end

      def payload
        result = {
          license: Avo.configuration.license,
          license_key: Avo.configuration.license_key,
          avo_version: Avo::VERSION,
          rails_version: Rails::VERSION::STRING,
          ruby_version: RUBY_VERSION,
          environment: Rails.env,
          ip: current_request&.ip,
          host: current_request&.host,
          port: current_request&.port,
          app_name: app_name
        }

        # metadata = Avo::Services::DebugService.avo_metadata
        # if metadata[:resources_count] != 0
        #   result[:avo_metadata] = "metadata"
        # end

        result
      end

      def cached_response
        cache_store.read self.class.cache_key
      end

      private

      def make_request
        return cached_response if has_cached_response

        begin
          perform_and_cache_request
        rescue Errno::EHOSTUNREACH => exception
          cache_and_return_error "HTTP host not reachable error.", exception.message
        rescue Errno::ECONNRESET => exception
          cache_and_return_error "HTTP connection reset error.", exception.message
        rescue Errno::ECONNREFUSED => exception
          cache_and_return_error "HTTP connection refused error.", exception.message
        rescue OpenSSL::SSL::SSLError => exception
          cache_and_return_error "OpenSSL error.", exception.message
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

        if hq_response.code == 200
          cache_response response: hq_response.parsed_response
        end
      end

      def cache_response(response: nil, time: CACHE_TIME)
        response = normalize_response response

        response.merge!(
          expiry: time,
          fetched_at: Time.now,
          **payload
        ).stringify_keys!

        cache_store.write(self.class.cache_key, response, expires_in: time)

        response
      end

      def normalize_response(response)
        if response.is_a? Hash
          response
        else
          {
            normalized_response: JSON.stringify(response)
          }
        end
        response.merge({})
      rescue
        {
          normalized_response: "rescued"
        }
      end

      def perform_request
        Avo.logger.debug "Performing request to avohq.io API to check license availability." if Rails.env.development?

        if Rails.env.test?
          OpenStruct.new({code: 200, parsed_response: {id: "pro", valid: true}})
        else
          HTTParty.post ENDPOINT, body: payload.to_json, headers: {"Content-type": "application/json"}, timeout: REQUEST_TIMEOUT
        end
      end

      def app_name
        Rails.application.class.to_s.split("::").first
      rescue
        nil
      end

      def cache_and_return_error(error, exception_message = "")
        cache_response response: {
          id: Avo.configuration.license,
          valid: true,
          error: error,
          exception_message: exception_message
        }.stringify_keys, time: 5.minutes.to_i
      end

      def has_cached_response
        cache_store.exist? self.class.cache_key
      end
    end
  end
end
