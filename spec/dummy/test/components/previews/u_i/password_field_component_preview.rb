# frozen_string_literal: true

module UI
  class PasswordFieldComponentPreview < ViewComponent::Preview
    # Password Field - States
    # -----------------------
    # Renders password field variants: error, success, hidden password,
    # show password (visible), and hidden with loading.
    #
    def default
      render_with_template(template: "u_i/password_field_component_preview/default")
    end
  end
end
