# frozen_string_literal: true

class Avo::Fields::FilesField::EditComponent < Avo::Fields::EditComponent
  include Avo::Fields::Concerns::FileAuthorization
  def field_input_args
    super.merge(
      {
        value: nil, # hack to exclud value for this  component
        accept: @field.accept,
        direct_upload: @field.direct_upload,
        disabled: disabled?,
        multiple: true,
        class: "w-full"
      }
    ).compact
  end
end
