# frozen_string_literal: true

class Avo::Fields::BadgeField::EditComponent < Avo::Fields::EditComponent
  # The badge options map values to colors and need not list every value. Offer the record's own value too,
  # or the select falls back to blank and the next save erases it.
  def choices
    (@field.options_for_filter.map(&:to_s) | [@form.object.try(@field.id).to_s]).compact_blank
  end
end
