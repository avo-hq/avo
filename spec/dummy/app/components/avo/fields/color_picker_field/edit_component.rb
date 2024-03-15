# frozen_string_literal: true

class Avo::Fields::ColorPickerField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        class: helpers.input_classes("w-full py-0", has_error: @field.record_errors.include?(@field.id)).gsub("py-2", "")
      }
    )
  end
end
