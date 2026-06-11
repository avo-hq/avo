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

  # Resolve a sub-item's URL. A Link carries its own stored `path`; the other
  # types (resource, dashboard, board, page) don't, so we derive the URL from the
  # item type the same way ItemSwitcherComponent does for top-level items.
  def subitem_path(item)
    return item.path if item.try(:path).present?

    case item
    when Avo::Menu::Resource then helpers.resources_path(resource: item.parsed_resource, **item.fetch_params)
    when Avo::Menu::Dashboard then helpers.avo_dashboards.dashboard_path(item.parsed_dashboard)
    when Avo::Menu::Board then helpers.avo_kanban.board_path(item.record)
    when Avo::Menu::Page then item.navigation_path
    when Avo::Menu::Action then item.navigation_path(helpers)
    end
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
    # Keep the parent expanded when it is active itself, or when one of its
    # sub-items is active (e.g. a nested resource that lives at a sibling path).
    helpers.is_active_link?(@path, @active) || active_item_index.present?
  end

  def link_icon
    @icon
  end

  def active_item_index
    return @active_item_index if defined?(@active_item_index)

    active = @items.to_a.each_with_index.filter_map do |item, index|
      path = subitem_path(item)
      [index, path.length] if path.present? && helpers.is_active_link?(path, @active)
    end

    # Favor the most specific match (longest path) so a record sub-item wins the
    # indicator over the resource index it lives under, instead of the first match.
    @active_item_index = active.max_by(&:last)&.first
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
