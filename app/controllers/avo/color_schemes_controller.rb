require_dependency "avo/application_controller"

module Avo
  class ColorSchemesController < ApplicationController
    def create
      if params[:color_scheme].present?
        return unless params[:color_scheme].in?(["auto", "light", "dark"])

        cookies[:color_scheme] = if params[:color_scheme] == "auto"
          nil
        else
          params[:color_scheme]
        end
      end

      if params[:theme].present?
        return unless params[:theme].in?(["brand", "slate", "stone"])

        cookies[:theme] = if params[:theme] == "brand"
          nil
        else
          params[:theme]
        end
      end

      render turbo_stream: turbo_stream.reload
    end
  end
end
