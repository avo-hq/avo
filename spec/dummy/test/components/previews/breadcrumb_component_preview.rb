class BreadcrumbComponentPreview < ViewComponent::Preview
  # Breadcrumb Component
  # --------------------
  # A navigation component that displays a breadcrumb trail.
  # Supports multiple items, different separators, and truncation.
  #
  # @param separator select { choices: [>, /, :] } ">"
  # @param truncate toggle "false"
  def default(
    separator: ">",
    truncate: false
  )
    items = [
      {text: "Home", url: "https://example.com/home"},
      {text: "Page 1", url: "https://example.com/page1"},
      {text: "Page 2", url: "https://example.com/page2"},
      {text: "Page 3", url: "https://example.com/page3"},
      {text: "Page 4", current: true}
    ]

    render Avo::BreadcrumbsComponent.new(
      items: items,
      separator: separator,
      truncate: truncate
    )
  end

  # Simple breadcrumb path
  def simple_path
    items = [
      {text: "Home", url: "https://example.com/home"},
      {text: "Current Page", current: true}
    ]

    render Avo::BreadcrumbsComponent.new(items: items)
  end

  # Breadcrumb with chevron separator (default)
  def with_chevron_separator
    items = [
      {text: "Home", url: "https://example.com/home"},
      {text: "Page 1", url: "https://example.com/page1"},
      {text: "Page 2", url: "https://example.com/page2"},
      {text: "Page 3", url: "https://example.com/page3"},
      {text: "Page 4", current: true}
    ]

    render Avo::BreadcrumbsComponent.new(
      items: items,
      separator: ">"
    )
  end

  # Breadcrumb with slash separator
  def with_slash_separator
    items = [
      {text: "Home", url: "https://example.com/home"},
      {text: "Page 1", url: "https://example.com/page1"},
      {text: "Page 2", url: "https://example.com/page2"},
      {text: "Page 3", url: "https://example.com/page3"},
      {text: "Page 4", current: true}
    ]

    render Avo::BreadcrumbsComponent.new(
      items: items,
      separator: "/"
    )
  end

  # Breadcrumb with colon separator
  def with_colon_separator
    items = [
      {text: "Home", url: "https://example.com/home"},
      {text: "Page 1", url: "https://example.com/page1"},
      {text: "Page 2", current: true}
    ]

    render Avo::BreadcrumbsComponent.new(
      items: items,
      separator: ":"
    )
  end

  # Breadcrumb with icons
  def with_icons
    items = [
      {text: "Home", url: "https://example.com/home", icon: "heroicons/outline/home"},
      {text: "Dashboard", url: "https://example.com/dashboard", icon: "heroicons/outline/chart-bar"},
      {text: "Settings", url: "https://example.com/settings", icon: "heroicons/outline/cog"},
      {text: "Profile", current: true, icon: "heroicons/outline/user"}
    ]

    render Avo::BreadcrumbsComponent.new(items: items)
  end

  # Truncated breadcrumb (shows ellipsis)
  def truncated
    items = [
      {text: "Home", url: "https://example.com/home"},
      {text: "Page 1", url: "https://example.com/page1"},
      {text: "Page 2", url: "https://example.com/page2"},
      {text: "Page 3", url: "https://example.com/page3"},
      {text: "Page 4", url: "https://example.com/page4"},
      {text: "Page 5", url: "https://example.com/page5"},
      {text: "Page 6", url: "https://example.com/page6"},
      {text: "Page 7", current: true}
    ]

    render Avo::BreadcrumbsComponent.new(
      items: items,
      truncate: true,
      max_items: 5
    )
  end

  # Long breadcrumb path
  def long_path
    items = [
      {text: "Home", url: "https://example.com/home"},
      {text: "Category", url: "https://example.com/category"},
      {text: "Subcategory", url: "https://example.com/subcategory"},
      {text: "Item", url: "https://example.com/item"},
      {text: "Details", url: "https://example.com/details"},
      {text: "Edit", current: true}
    ]

    render Avo::BreadcrumbsComponent.new(items: items)
  end

  # All variants showcase
  def variants
    render_with_template(
      template: "breadcrumb_component_preview/variants"
    )
  end
end
