# frozen_string_literal: true

# Shared with avo-licensing's status page, so the plugin list doesn't drift between the two.
class Avo::Debug::PluginsComponent < Avo::BaseComponent
  def plugins
    Avo.plugin_manager.plugins
  end

  def version_badge(gem_name, version)
    return if gem_name.blank?

    latest = Avo::Services::GemVersions.latest[gem_name]
    return if latest.blank?

    up_to_date = Avo::Services::GemVersions.latest?(gem_name, version)
    tooltip = up_to_date ? "Latest version" : "Behind: #{latest} is available"
    icon = up_to_date ? "tabler/outline/circle-check" : "tabler/outline/circle-arrow-up"

    tag.span(helpers.svg(icon, class: "size-4"),
      class: "status-page__plugin-badge status-page__plugin-badge--#{up_to_date ? "latest" : "behind"}",
      title: tooltip, aria: {label: tooltip}, data: {tippy: "tooltip"})
  end
end
