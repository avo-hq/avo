# frozen_string_literal: true

class UI::DropdownCardComponentPreview < ViewComponent::Preview
  layout "component_preview"

  # @!group Examples

  # Default dropdown card variants (design only)
  def default
    render_with_template(template: "u_i/dropdown_card_component_preview/default")
  end

  # @!endgroup
end
