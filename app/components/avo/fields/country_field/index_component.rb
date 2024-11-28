# frozen_string_literal: true

class Avo::Fields::CountryField::IndexComponent < Avo::Fields::IndexComponent
  private

  def field_value
    @field.display_code ? @field.value : @field.countries[@field.value]
  end
end
