# frozen_string_literal: true

class Avo::CalloutComponent < Avo::BaseComponent
  unless defined?(DEFAULT_ICONS)
    DEFAULT_ICONS = {
      info: "tabler/outline/info-circle",
      success: "tabler/outline/circle-check",
      warning: "tabler/outline/exclamation-circle",
      error: "tabler/outline/circle-x"
    }.freeze
  end

  prop :type, default: :info
  prop :title
  prop :body
  prop :icon
  prop :url
  prop :target
  # The resource the callout is declared on. A custom `component:` reads the record from it.
  prop :resource

  def render?
    @title.present? || @body.present?
  end

  # `icon: false` drops the icon; no icon picks the one that matches the type.
  def icon
    return if @icon == false

    @icon.presence || DEFAULT_ICONS[@type.to_sym]
  end

  def wrapper_element(args = {}, &block)
    if @url.present?
      link_to @url, **args, target: @target, &block
    else
      tag.div(**args, &block)
    end
  end
end
