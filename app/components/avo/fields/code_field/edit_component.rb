# frozen_string_literal: true

class Avo::Fields::CodeField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full"),
        data: {
          "code-field-target": "element",
          view: view,
          language: @field.language,
          theme: @field.theme,
          "tab-size": @field.tab_size,
          "read-only": disabled?,
          "indent-with-tabs": @field.indent_with_tabs,
          "line-wrapping": @field.line_wrapping,
          **@field.get_html(:data, view: view, element: :input)
        }
      }
    )
  end
end
