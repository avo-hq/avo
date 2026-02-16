module Avo
  module UserPreferences
    class DBConfigAdapter
      def initialize(key_prefix: "avo_preferences")
        @key_prefix = key_prefix

        unless defined?(::DBConfig)
          raise Avo::ConfigurationError,
            "The db_config gem is required to use Avo::UserPreferences::DBConfigAdapter. " \
            "Add `gem 'db_config'` to your Gemfile."
        end
      end

      def load(user:, request:)
        stored = ::DBConfig.get(storage_key(user))
        return {} if stored.nil?

        stored.symbolize_keys
      end

      def save(user:, request:, key:, value:, preferences:)
        ::DBConfig.set(storage_key(user), preferences)
      end

      private

      def storage_key(user)
        "#{@key_prefix}_#{user.id}"
      end
    end
  end
end
