module Avo
  class HQ
    attr_accessor :cache_key
    attr_accessor :endpoint
    attr_accessor :timeout
    attr_accessor :current_request

    def initialize(current_request)
      @cache_key = 'avo.avohq.response'
      @endpoint = 'https://avohq.io/api/v1/licenses/check'
      @timeout = 5
      @current_request = current_request
    end

    def response
      @response or request
    end

    def request
      if has_cached_response
        return cached_response
      end

      begin
        perform_and_cache_request
      rescue HTTParty::Error => exception
        handle_response_exceptions exception
      end
    end

    def handle_response_exceptions(exception)
      return cache_and_return_error if exception.class == SocketError
    end

    def handle_hq_error(response)
      cache_response 5.minutes, { error: 'Internal server error' }.stringify_keys
    end

    def cache_and_return_error
      cache_response 5.minutes, { error: 'Connection error' }.stringify_keys
    end

    def perform_and_cache_request
      hq_response = perform_request

      return handle_hq_error hq_response if hq_response.code == 500

      cache_response 1.hour, hq_response.parsed_response if hq_response.code == 200
    end

    def cache_response(time, response)
      response.merge!(
        expiry: time,
        **payload,
      )

      Rails.cache.write(cache_key, response, expires_in: time)

      @response = response

      response
    end

    def perform_request
      puts 'Performing request to avohq.io API to check license availability.'.inspect

      HTTParty.post endpoint, body: payload.to_json, headers: { 'Content-type': 'application/json' }, timeout: timeout
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
      }
    end

    def has_cached_response
      Rails.cache.exist? cache_key
    end

    def cached_response
      Rails.cache.read cache_key
    end
  end
end
