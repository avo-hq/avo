# frozen_string_literal: true

class Avo::Fields::MarkdownField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("w-full js-has-easy-mde-editor"),
        data: {
          view: view,
          "easy-mde-target": "element",
          "component-options": @field.options.to_json,
        }
      }
    )
  end
end
