# frozen_string_literal: true

class UI::ScopeTabsComponentPreview < ViewComponent::Preview
  # @!group Interactive Playground

  # Interactive scope tabs with customizable options
  # @param tab_count number "Number of tabs"
  # @param active_tab number "Index of active tab (0-based)"
  # @param show_icons toggle "Show icons on tabs"
  def playground(
    tab_count: 5,
    active_tab: 0,
    show_icons: false
  )
    render_with_template(
      template: "u_i/scope_tabs_component_preview/playground",
      locals: {
        tab_count: tab_count.to_i,
        active_tab: active_tab.to_i,
        show_icons: show_icons
      }
    )
  end

  # @!endgroup

  # @!group Standard Examples
  def standard
    render_with_template(template: "u_i/scope_tabs_component_preview/standard")
  end

  # @!endgroup
end



