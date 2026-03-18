# frozen_string_literal: true

class FiltersComponentPreview < ViewComponent::Preview
  include Avo::ApplicationHelper
  include ::ApplicationHelper

  layout "component_preview"

  # Design-only: filters panel with all filter types as static placeholders
  #
  # @param applied toggle "false" "Show with applied state (Reset all link, pre-filled values)"
  def default(applied: false)
    render_with_template(
      template: "filters_component_preview/default",
      locals: { applied: applied }
    )
  end

  # Design-only: filters panel with applied state
  def with_applied
    render_with_template(
      template: "filters_component_preview/with_applied"
    )
  end
end
