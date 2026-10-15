module Avo
  class AppearanceSettingsController < Avo::ApplicationController
    def update
      appearance = Avo.configuration.appearance

      if appearance.save_settings_block.blank?
        return render json: {ok: false, error: "No save_settings block configured"}, status: :unprocessable_entity
      end

      payload = params.key?(:appearance_setting) ? params.require(:appearance_setting) : params
      settings = payload.permit(:color_scheme, :neutral, :accent, *festivity_preference_keys).to_h.symbolize_keys

      Avo::ExecutionContext.new(
        target: appearance.save_settings_block,
        settings: settings,
        current_user: _current_user
      ).handle

      render json: {ok: true}
    end

    private

    # Festivity opt-outs are saved by name ("festivity_christmas" => "off").
    def festivity_preference_keys
      Avo::Configuration::FESTIVITIES.map { |festivity| Avo.configuration.appearance.festivity_preference_key(festivity) }
    end
  end
end
