# frozen_string_literal: true

class UI::TabsComponentPreview < ViewComponent::Preview
  # @!group Type Group (No Border)

  # Simple tabs without icons - group style
  def group_basic
    render Avo::UI::TabsComponent.new(variant: :group) do |tab|
      tab.with_item label: "Overview", active: true
      tab.with_item label: "Settings"
      tab.with_item label: "Analytics"
    end
  end

  # Tabs with icons - group style
  def group_with_icons
    active_tab = 1
    render Avo::UI::TabsComponent.new(variant: :group) do |tabs|
      4.times do |index|
        tabs.with_item label: "Tab", icon: "heroicons/outline/external-link", active: index == active_tab
      end
    end
  end

  # @!endgroup

  # @!group Type Scope (With Border)

  # Tabs with border - scope style
  def scope_basic
    active_tab = 1
    render Avo::UI::TabsComponent.new(variant: :scope) do |tabs|
      5.times do |index|
        tabs.with_item label: "Tab", icon: "heroicons/outline/external-link", active: index == active_tab
      end
    end
  end

  # Tabs with border without icons - scope style
  def scope_no_icons
    active_tab = 1
    render Avo::UI::TabsComponent.new(variant: :scope) do |tabs|
      5.times do |index|
        tabs.with_item label: "Tab", active: index == active_tab
      end
    end
  end

  # @!endgroup

  # @!group Array API Examples

  # Simple array API - pass tabs as array of strings
  def array_api_simple
    tabs_data = ["Overview", "Settings", "Analytics", "Files", "Settings"]
    active_tab = 1

    render Avo::UI::TabsComponent.new(variant: :group) do |tabs|
      tabs_data.each_with_index do |label, index|
        tabs.with_item label: label, active: index == active_tab
      end
    end
  end

  # Array API with hash data - more control
  def array_api_advanced
    tabs_data = [
      {label: "Overview", icon: "heroicons/outline/home", href: "/overview"},
      {label: "Settings", icon: "heroicons/outline/cog", href: "/settings"},
      {label: "Analytics", icon: "heroicons/outline/chart-bar", href: "/analytics"},
      {label: "Files", icon: "heroicons/outline/folder", href: "/files"}
    ]
    active_tab = 2

    render Avo::UI::TabsComponent.new() do |tabs|
      tabs_data.each_with_index do |tab, index|
        tabs.with_item(
          label: tab[:label],
          icon: tab[:icon],
          href: tab[:href],
          active: index == active_tab
        )
      end
    end
  end

  # Array API with scope variant (borders)
  def array_api_scope
    tabs_data = [
      {label: "Overview", icon: "heroicons/outline/external-link"},
      {label: "Settings", icon: "heroicons/outline/external-link"},
      {label: "Analytics", icon: "heroicons/outline/external-link"},
      {label: "Files", icon: "heroicons/outline/external-link"}
    ]
    active_tab = 2

    render Avo::UI::TabsComponent.new(variant: :scope) do |tabs|
      tabs_data.each_with_index do |tab, index|
        tabs.with_item(
          label: tab[:label],
          icon: tab[:icon],
          active: index == active_tab
        )
      end
    end
  end

  # @!endgroup

  # @!group Interactive Playground

  # Interactive tabs with customizable options
  # @param variant select { choices: [group, scope] } "Tab variant style"
  # @param tab_count number "Number of tabs"
  # @param active_tab number "Index of active tab (0-based)"
  # @param show_icons toggle "Show icons on tabs"
  def playground(
    variant: :group,
    tab_count: 5,
    active_tab: 0,
    show_icons: false
  )
    render_with_template(
      template: "u_i/tabs_component_preview/playground",
      locals: {
        variant: variant.to_sym,
        tab_count: tab_count.to_i,
        active_tab: active_tab.to_i,
        show_icons: show_icons
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
