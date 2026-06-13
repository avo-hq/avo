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
    uri = URI(@path)
    # Paths without a scheme are always internal (relative app paths).
    return false if uri.scheme.blank?

    # A link with a scheme is internal only when its path is mounted under Avo.
    # Compare against the URI path component, not the whole URL string, otherwise
    # hosts like "avohq.io" falsely match a "/avo" mount path (via "//avohq.io").
    # Use root_path_without_url so prefix_path + mount_path setups are recognized.
    !uri.path.start_with?(helpers.root_path_without_url)
  rescue URI::InvalidURIError
    true
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

    data.merge(hotkey: hotkey)
  end
end
