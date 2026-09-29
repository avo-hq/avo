# frozen_string_literal: true

class Avo::Fields::BadgeField::EditComponent < Avo::Fields::EditComponent
  # Options are configured as strings or symbols; the selected value comes back from the record as a string.
  def options
    options_for_select(@field.options_for_filter.map(&:to_s).uniq, selected: @field.value.to_s)
  end
end
