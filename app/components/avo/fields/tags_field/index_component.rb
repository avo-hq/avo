# frozen_string_literal: true

class Avo::Fields::TagsField::IndexComponent < Avo::Fields::IndexComponent
  def value
    @field.field_value
  end
end
