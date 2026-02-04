# frozen_string_literal: true

module UI
  class DateFieldComponentPreview < ViewComponent::Preview
    # Date Field - States
    # -------------------
    # Renders date field variants: default, error, success, and disabled states.
    #
    def default
      render_with_template(template: "u_i/date_field_component_preview/default")
    end
  end
end
