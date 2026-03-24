# frozen_string_literal: true

require "view_component/version"

class Avo::Sidebar::LinkComponent < Avo::BaseComponent
  prop :label
  prop :path
  prop :active, default: :inclusive do |value|
    value&.to_sym
  end
  prop :target do |value|
    value&.to_sym
  end
  prop :data, default: {}.freeze
  prop :icon
  prop :reserve_icon_space, default: false
  prop :args, kind: :**, default: {}.freeze
  prop :items
  prop :hotkey, default: nil

  def link_data
    build_link_data(@data, @hotkey)
  end

  def subitem_data(item)
    build_link_data(item.data, item.hotkey)
  end

  def is_external?
    # If the path contains the scheme, check if it includes the root path or not
    return !@path.include?(helpers.mount_path) if URI(@path).scheme.present?

    false
  end

  # For external links active_link_to marks them all as active.
  def link_method
    is_external? ? :link_to : :active_link_to
  end

  # Backwards compatibility with ViewComponent 3.x
  def link_caller
    if Gem::Version.new(ViewComponent::VERSION::STRING) >= Gem::Version.new("4.0.0")
      helpers
    else
      self
    end
  end

  def parent_link_active?
    return false if @path.blank?
    helpers.is_active_link?(@path, @active)
  end

  def link_icon
    @icon
  end

  def active_item_index
    return @active_item_index if defined?(@active_item_index)

    @active_item_index = @items&.index do |item|
      item.path.present? && helpers.is_active_link?(item.path, @active)
    end
  end

  def subitem_bar_class(index)
    active_idx = active_item_index
    return "" if active_idx.nil?

    if index == active_idx
      "sidebar-subitem--bar-active"
    elsif index < active_idx
      "sidebar-subitem--bar-pass"
    else
      ""
    end
  end

  private

  def build_link_data(data, hotkey)
    return data if hotkey.blank?

    hotkey_data("keydown.#{hotkey}@window->hotkey-trigger#click", **data)
  end
end
