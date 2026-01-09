# frozen_string_literal: true

class UI::TabsComponentPreview < ViewComponent::Preview
  # @!group Interactive Playground

  # Interactive tabs with customizable options
  # @param tab_count number "Number of tabs"
  # @param active_tab number "Index of active tab (0-based)"
  # @param show_icons toggle "Show icons on tabs"
  # @param variant select "Tab variant" { choices: [scope, group], default: scope }
  def playground(
    tab_count: 5,
    active_tab: 0,
    show_icons: false,
    variant: :scope
  )
    render_with_template(
      template: "u_i/tabs_component_preview/playground",
      locals: {
        tab_count: tab_count.to_i,
        active_tab: active_tab.to_i,
        show_icons: show_icons,
        variant: variant.to_sym
      }
    )
  end

  # @!endgroup

  # @!group Standard Examples

  # All variants showcase
  def showcase
    render_with_template(template: "u_i/tabs_component_preview/showcase")
  end

  # @!endgroup
end
