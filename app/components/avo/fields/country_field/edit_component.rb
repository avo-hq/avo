# frozen_string_literal: true

class Avo::Fields::CountryField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        aria: {
          placeholder: @field.placeholder
        },
        class: classes("w-full"),
        placeholder: @field.include_blank.present? ? nil : @field.placeholder
      }
    )
  end
end
