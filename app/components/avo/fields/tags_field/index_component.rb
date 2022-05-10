# frozen_string_literal: true

class Avo::Fields::TagsField::IndexComponent < Avo::Fields::IndexComponent
  include Avo::Fields::Concerns::ItemLabels

  def value
    @field.field_value
  end
end
