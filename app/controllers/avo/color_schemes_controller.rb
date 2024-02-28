require_dependency "avo/application_controller"

module Avo
  class ColorSchemesController < ApplicationController
    def create
      return unless params[:color_scheme].in?(["auto", "light", "dark"])

      cookies[:color_scheme] = if params[:color_scheme] == "auto"
        nil
      else
        params[:color_scheme]
      end

      render turbo_stream: turbo_stream.reload
    end
  end
end
