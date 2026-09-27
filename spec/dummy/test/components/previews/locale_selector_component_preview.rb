class LocaleSelectorComponentPreview < ViewComponent::Preview
  # Locale Selector Component
  # -------------------------
  # The "Language" entry of the profile menu. Click it to expand the list of
  # languages; each is labeled in its own script and the current one is marked.
  # The list comes from `config.locale_selector` unless `locales` is passed.
  def default
    render_with_template(
      template: "locale_selector_component_preview/default"
    )
  end
end
