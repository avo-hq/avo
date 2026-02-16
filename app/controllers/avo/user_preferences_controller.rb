module Avo
  class UserPreferencesController < BaseApplicationController
    skip_before_action :set_resource_name
    skip_before_action :set_authorization
    skip_before_action :set_view
    skip_before_action :_authenticate!

    before_action :ensure_user_preferences_configured
    before_action :ensure_authenticated

    def show
      render json: {preferences: user_preferences}
    end

    def update
      prefs = preferences_params
      return if prefs.nil? # already rendered error in preferences_params

      allowed_keys = Avo.configuration.all_user_preference_keys.map(&:to_s)
      filtered = prefs.select { |key, _| key.to_s.in?(allowed_keys) }

      filtered.each do |key, value|
        Avo.configuration.save_user_preferences(
          user: _current_user,
          request: request,
          key: key.to_sym,
          value: value,
          preferences: filtered
        )
      end

      render json: {status: "ok"}, status: :ok
    rescue => error
      render json: {error: error.message}, status: :unprocessable_entity
    end

    private

    def ensure_user_preferences_configured
      return if Avo.configuration.user_preferences_configured?

      render json: {error: "not_configured"}, status: :not_found
    end

    def ensure_authenticated
      return if _current_user.present?

      render json: {error: "unauthorized"}, status: :unauthorized
    end

    def user_preferences
      load_user_preferences
      @user_preferences || {}
    end

    def preferences_params
      body = JSON.parse(request.body.read)
      body.fetch("preferences", {})
    rescue JSON::ParserError
      render json: {error: "invalid JSON body"}, status: :bad_request
      nil
    end
  end
end
