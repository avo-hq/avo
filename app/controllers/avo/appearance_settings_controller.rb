module Avo
  class AppearanceSettingsController < Avo::ApplicationController
    def update
      appearance = Avo.configuration.appearance

      if appearance.save_settings_block.blank?
        return render json: {ok: false, error: "No save_settings block configured"}, status: :unprocessable_entity
      end

      payload = params.key?(:appearance_setting) ? params.require(:appearance_setting) : params
      settings = payload.permit(:color_scheme, :neutral, :accent, :theme, :density, :roundness).to_h.symbolize_keys
      settings.delete(:theme) unless appearance.themes_enabled?
      unless appearance.density_picker? && Avo::Configuration::Appearance::DENSITIES.map(&:to_s).include?(settings[:density])
        settings.delete(:density)
      end
      unless appearance.roundness_picker? && Avo::Configuration::Appearance::ROUNDNESSES.map(&:to_s).include?(settings[:roundness])
        settings.delete(:roundness)
      end

      Avo::ExecutionContext.new(
        target: appearance.save_settings_block,
        settings: settings,
        current_user: _current_user
      ).handle

      render json: {ok: true}
    end
  end
end
