# frozen_string_literal: true

class Avo::Fields::FileField::EditComponent < Avo::Fields::EditComponent
  include Avo::Fields::Concerns::FileAuthorization
  def field_input_args
    super.merge(
      {
        value: nil,
        accept: @field.accept,
        direct_upload: @field.direct_upload,
        disabled: disabled?,
        class: "w-full"
      }
    ).compact
  end
end
