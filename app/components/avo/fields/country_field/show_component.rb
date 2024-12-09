# frozen_string_literal: true

class Avo::Fields::CountryField::ShowComponent < Avo::Fields::ShowComponent
  private

  def field_value
    @field.display_code ? @field.value : @field.countries[@field.value]
  end
end
