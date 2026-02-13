# frozen_string_literal: true

module UI
  class SearchInputComponentPreview < ViewComponent::Preview
    layout "component_preview"

    # @!group Examples

    # Search input: 3 columns (sm, md, lg) and 2 rows (with shortcut, without shortcut)
    def default
      render_with_template(template: "u_i/search_input_component_preview/default")
    end

    # @!endgroup
  end
end
