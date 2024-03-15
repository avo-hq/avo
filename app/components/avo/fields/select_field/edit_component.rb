# frozen_string_literal: true

class Avo::Fields::SelectField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        aria: {
          placeholder: @field.placeholder
        },
        class: classes("w-full"),
        value: @field.record.present? ? @field.record[@field.id] : @field.value,
        placeholder: @field.include_blank.present? ? nil : @field.placeholder,
        autocomplete: @field.autocomplete
      }
    )
  end
end
