# frozen_string_literal: true

class Avo::Fields::BooleanField::EditComponent < Avo::Fields::EditComponent
  delegate :as_toggle?, to: :@field

  private

  def checkbox_data_attributes
    base_data = @field.get_html(:data, view: view, element: :input) || {}

    if as_toggle?
      base_data.merge(avo_boolean_toggle_target: "checkbox")
    else
      base_data
    end
  end

  def common_checkbox_attributes
    @common_checkbox_attributes ||= {
      value: @field.value,
      checked: @field.value,
      disabled: disabled?,
      autofocus: @autofocus,
      id: "#{@field.id}_checkbox",
      data: checkbox_data_attributes,
      style: @field.get_html(:style, view: view, element: :input),
      class: class_names(
        "text-lg h-4 w-4 checked:bg-primary-400 focus:checked:!bg-primary-400 rounded",
        @field.get_html(:classes, view: view, element: :input),
        "sr-only": as_toggle?
      ),
    }
  end
end
