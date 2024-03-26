# frozen_string_literal: true

class Avo::Fields::TagsField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: classes("hidden w-full border-primary-500 focus-within:border-primary-500"),
        data: {
          tags_field_target: :input,
        },
        value: @field.field_value.to_json
      }
    )
  end
end
