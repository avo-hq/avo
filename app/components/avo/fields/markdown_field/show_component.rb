# frozen_string_literal: true

class Avo::Fields::MarkdownField::ShowComponent < Avo::Fields::ShowComponent
  def parsed_body
    Avo::Fields::MarkdownField.parser.render(@field.value)
  end
end
