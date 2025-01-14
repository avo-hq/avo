module Avo
  class MarkdownPreviewsController < ApplicationController
    def create
      renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
      parser = Redcarpet::Markdown.new(renderer, lax_spacing: true, fenced_code_blocks: true, hard_wrap: true)

      @result = parser.render(params[:body])
    end
  end
end
