# frozen_string_literal: true

class Avo::Fields::SelectField::EditComponent < Avo::Fields::EditComponent
  def options
    if @field.grouped_options.present?
      grouped_options_for_select(@field.grouped_options, selected: @field.value)
    else
      options_for_select(@field.options_for_select, selected: @field.value)
    end
  end
end
