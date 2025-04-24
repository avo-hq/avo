module Avo
  class ThemesController < ApplicationController
    def update
      Avo.configuration.theme.set_variable(property: params[:property], value: params[:value])

      respond
    end

    def destroy
      Avo.configuration.theme.reset_variable(property: params[:property])

      respond
    end

    private

    def respond
      render turbo_stream: [
        turbo_stream.replace("avo-theme-variables", partial: "avo/theme/variables"),
      ]
    end
  end
end
