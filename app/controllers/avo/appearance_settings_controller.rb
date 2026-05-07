module Avo
  class AppearanceSettingsController < ApplicationController
    def update
      if Avo.configuration.appearance.save_settings_block.blank?
        return render json: {ok: false, error: "No save_settings block configured"}, status: :unprocessable_entity
      end

      settings = params.permit(:color_scheme, :neutral, :accent).to_h.symbolize_keys

      Avo::ExecutionContext.new(
        target: Avo.configuration.appearance.save_settings_block,
        settings: settings,
        current_user: _current_user
      ).handle

      render json: {ok: true}
    end
  end
end
