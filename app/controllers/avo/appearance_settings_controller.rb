module Avo
  class AppearanceSettingsController < ApplicationController
    def update
      appearance = Avo.configuration.appearance

      if appearance.save_settings_block.blank?
        return render json: {ok: false, error: "No save_settings block configured"}, status: :unprocessable_entity
      end

      payload = params.key?(:appearance_setting) ? params.require(:appearance_setting) : params
      settings = payload.permit(:color_scheme, :neutral, :accent).to_h.symbolize_keys

      Avo::ExecutionContext.new(
        target: appearance.save_settings_block,
        settings: settings,
        current_user: _current_user
      ).handle

      render json: {ok: true}
    end
  end
end
