class BreadcrumbElementComponentPreview < ViewComponent::Preview
  # Breadcrumb Element Component
  # ----------------------------
  # A single breadcrumb item that can be a link or current page indicator.
  # Supports icons and custom separators.
  #
  # @param text text "Page"
  # @param url text "https://example.com/page"
  # @param icon text "heroicons/outline/home"
  # @param separator text ">"
  # @param current toggle "false"
  def default(
    text: "Page",
    url: "https://example.com/page",
    icon: nil,
    separator: ">",
    current: false
  )
    render_with_template(
      template: "breadcrumb_element_component_preview/default",
      locals: {
        text: text,
        url: url,
        icon: icon,
        separator: separator,
        current: current
      }
    )
  end

  # Link element (default state)
  def link_element
    render Avo::BreadcrumbElementComponent.new(
      text: "Home",
      url: "https://example.com/home"
    )
  end

  # Current page element (non-clickable)
  def current_element
    render Avo::BreadcrumbElementComponent.new(
      text: "Current Page",
      current: true
    )
  end

  # Element with icon
  def with_icon
    render Avo::BreadcrumbElementComponent.new(
      text: "Dashboard",
      url: "https://example.com/dashboard",
      icon: "heroicons/outline/home"
    )
  end

  # Element with separator
  def with_separator
    render Avo::BreadcrumbElementComponent.new(
      text: "Page",
      url: "https://example.com/page",
      separator: ">"
    )
  end

  # Element with slash separator
  def with_slash_separator
    render Avo::BreadcrumbElementComponent.new(
      text: "Page",
      url: "https://example.com/page",
      separator: "/"
    )
  end

  # Element with colon separator
  def with_colon_separator
    render Avo::BreadcrumbElementComponent.new(
      text: "Page",
      url: "https://example.com/page",
      separator: ":"
    )
  end

  # Current page with icon
  def current_with_icon
    render Avo::BreadcrumbElementComponent.new(
      text: "Current Page",
      icon: "heroicons/outline/document",
      current: true
    )
  end

  # All variants showcase
  def variants
    render_with_template(
      template: "breadcrumb_element_component_preview/variants"
    )
  end
end

