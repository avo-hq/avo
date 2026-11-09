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

  def add_on_state(plugin)
    license = Avo::Current.license
    return unless license.respond_to?(:enabled_feature?) && license.respond_to?(:valid?)
    return unless license_gated?(plugin)
    return if license.enabled_feature?(plugin.gem_name)

    text = if license.valid?
      "Your license doesn't include this add-on, so it's switched off."
    else
      "Switched off until your license is validated."
    end

    # Focusable so keyboard users reach the tooltip; the visible label keeps it from relying on hover.
    tag.span(safe_join([helpers.svg("tabler/outline/alert-triangle", class: "size-3.5"), "Off"]),
      class: "status-page__plugin-state status-page__plugin-state--off",
      title: text, tabindex: 0, aria: {label: "Off. #{text}"}, data: {tippy: "tooltip"})
  end

  # Paid add-ons depend on avo-licensing; free plugins and avo-licensing itself do not.
  def license_gated?(plugin)
    return false if plugin.gem_name.blank?

    Gem.loaded_specs[plugin.gem_name]&.dependencies&.any? { |dependency| dependency.name == "avo-licensing" } || false
  end
end
