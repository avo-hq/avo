module Avo
  module Licensing
    class HQ
      attr_accessor :current_request, :cache_store

      ENDPOINT = 'https://v3.avohq.io/api/v3/licenses/check'.freeze unless const_defined?(:ENDPOINT)
      REQUEST_TIMEOUT = 5 unless const_defined?(:REQUEST_TIMEOUT) # seconds
      CACHE_TIME = 6_000_000_000_000.hours.to_i unless const_defined?(:CACHE_TIME) # seconds

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

        parsed_time = Time.parse(cached_response['fetched_at'].to_s)
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
        {
          license: 'advanced',
          license_key: Avo.configuration.license_key,
          avo_version: Avo::VERSION,
          rails_version: Rails::VERSION::STRING,
          ruby_version: RUBY_VERSION,
          environment: Rails.env,
          ip: current_request&.ip,
          host: current_request&.host,
          port: current_request&.port,
          app_name:
        }

        # metadata = Avo::Services::DebugService.avo_metadata
        # if metadata[:resources_count] != 0
        #   result[:avo_metadata] = "metadata"
        # end
      end

      def cached_response
        cache_store.read self.class.cache_key
      end

      private

      def make_request
        return cached_response if has_cached_response

        begin
          perform_and_cache_request
        rescue Errno::EHOSTUNREACH => e
          cache_and_return_error 'HTTP host not reachable error.', e.message
        rescue Errno::ECONNRESET => e
          cache_and_return_error 'HTTP connection reset error.', e.message
        rescue Errno::ECONNREFUSED => e
          cache_and_return_error 'HTTP connection refused error.', e.message
        rescue OpenSSL::SSL::SSLError => e
          cache_and_return_error 'OpenSSL error.', e.message
        rescue HTTParty::Error => e
          cache_and_return_error 'HTTP client error.', e.message
        rescue Net::OpenTimeout => e
          cache_and_return_error 'Request timeout.', e.message
        rescue Net::ReadTimeout => e
          cache_and_return_error 'Request timeout.', e.message
        rescue SocketError => e
          cache_and_return_error 'Connection error.', e.message
        end
      end

      def perform_and_cache_request
        hq_response = perform_request

        return cache_and_return_error 'Avo HQ Internal server error.', hq_response.body if hq_response.code == 500

        return unless hq_response.code == 200

        cache_response response: hq_response.parsed_response
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
      rescue StandardError
        {
          normalized_response: 'rescued'
        }
      end

      def perform_request
        Avo.logger.debug 'Performing request to avohq.io API to check license availability.' if Rails.env.development?

        if Rails.env.test?
          OpenStruct.new({ code: 200, parsed_response: { id: 'pro', valid: true } })
        else
          HTTParty.post ENDPOINT, body: payload.to_json, headers: { "Content-type": 'application/json' },
                                  timeout: REQUEST_TIMEOUT
        end
      end

      def app_name
        Rails.application.class.to_s.split('::').first
      rescue StandardError
        nil
      end

      def cache_and_return_error(error, exception_message = '')
        cache_response response: {
          id: Avo.configuration.license,
          valid: true,
          error:,
          exception_message:
        }.stringify_keys, time: 5.minutes.to_i
      end

      def has_cached_response
        cache_store.exist? self.class.cache_key
      end
    end
  end
end
