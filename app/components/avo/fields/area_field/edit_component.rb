# frozen_string_literal: true

class Avo::Fields::AreaField::EditComponent < Avo::Fields::EditComponent
  def field_input_args
    super.merge(
      {
        value: field.value.to_s,
        class: classes("w-full")
      }
    )
  end
end
