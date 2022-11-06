module Avo
  module Concerns
    module ChecksRequirements
      def check_requirements
        puts "[Avo] Checking Avo requirements ->"

        check_api_only
        check_assets
        check_secret_key_base
      end

      def check_api_only
        raise MissingRequirementError.new "App set to api_only. Please set `config.api_only = false`." if Rails.configuration.api_only
      end

      def check_assets
        raise MissingRequirementError.new "Avo requires sprockets or propshaft. Please add one to your Gemfile." if Rails.application.assets.nil?
      end

      def check_secret_key_base
        raise MissingRequirementError.new "App requires sprockets or propshaft. Please add one to your Gemfile." unless has_secret_key_base?
      end

      private

      def has_secret_key_base?
        puts ["ENV[] ->", ENV["SECRET_KEY_BASE"] ].inspect
        puts ["Rails.application.credentials.secret_key_base->", Rails.application.credentials.secret_key_base].inspect
        puts ["Rails.application.secrets.secret_key_base->", Rails.application.secrets.secret_key_base].inspect
        puts (ENV["SECRET_KEY_BASE"] || Rails.application.credentials.secret_key_base || Rails.application.secrets.secret_key_base)
        (ENV["SECRET_KEY_BASE"] || Rails.application.credentials.secret_key_base || Rails.application.secrets.secret_key_base).present?
      end
    end
  end
end
