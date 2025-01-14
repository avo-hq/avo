# frozen_string_literal: true

class Avo::Fields::MarkdownField::ShowComponent < Avo::Fields::ShowComponent
  def parsed_body
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    parser = Redcarpet::Markdown.new(renderer, lax_spacing: true, fenced_code_blocks: true, hard_wrap: true)
    parser.render(@field.value)
  end
end
