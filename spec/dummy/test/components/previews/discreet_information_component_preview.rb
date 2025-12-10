class DiscreetInformationComponentPreview < ViewComponent::Preview
  # Discreet Information Component
  # -------------------------------
  # A component that displays information with a key (dark background),
  # text/url, and options icon.
  #
  # @param as select { choices: [icon, text, badge] } "text"
  # @param text text "john.doe@example.com"
  # @param icon text "email"
  # @param key text "Email"
  # @param url text "mailto:john.doe@example.com"
  # @param target select { choices: [self, blank] } "_self"
  def default(
    key: "key",
    text: "value",
    url: "https://example.com",
    target: "_blank",
    icon: "email",
    as: :badge
  )
    render_with_template(
      template: "discreet_information_component_preview/default",
      locals: {
        key: key,
        text: text,
        url: url,
        target: target,
        icon: icon,
        as: as
      }
    )
  end

  def with_external_link(
    key: "Website",
    text: "Visit site",
    url: "https://example.com",
    target: "_blank",
    options_icon: "more_vert"
  )
    render Avo::DiscreetInformationComponent.new(
      key: key,
      text: text,
      url: url,
      target: target
    )
  end

  def without_link(
    key: "Status",
    text: "Active",
    url: nil,
    options_icon: "more_vert"
  )
    render Avo::DiscreetInformationComponent.new(
      key: key,
      text: text,
      url: url
    )
  end

  def long_content(
    key: "Description",
    text: "This is a very long text that should be truncated when it exceeds the available space",
    url: "https://example.com/long-url-that-might-wrap",
    target: "_blank",
    options_icon: "more_vert"
  )
    render Avo::DiscreetInformationComponent.new(
      key: key,
      text: text,
      url: url,
      target: target
    )
  end

  def variants(
    key: "Type",
    text: "Example",
    url: "#",
    target: "_self",
    options_icon: "more_vert"
  )
    render_with_template(
      template: "discreet_information_component_preview/variants",
      locals: {
        key: key,
        text: text,
        url: url,
        target: target,
        options_icon: options_icon
      }
    )
  end
end

