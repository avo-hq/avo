module Avo
  class MarkdownPreviewsController < ApplicationController
    def create
      @result = Avo::Fields::MarkdownField.parser.render(params[:body])
    end
  end
end
