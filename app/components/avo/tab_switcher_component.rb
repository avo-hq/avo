# frozen_string_literal: true

class Avo::TabSwitcherComponent < Avo::BaseComponent
  include Avo::UrlHelpers
  include Avo::ApplicationHelper

  attr_reader :active_tab_name
  attr_reader :group
  attr_reader :current_tab
  attr_reader :tabs
  attr_reader :view
  attr_reader :style

  delegate :white_panel_classes, to: :helpers

  def initialize(resource:, group:, current_tab:, active_tab_name:, view:, style:)
    @active_tab_name = active_tab_name
    @resource = resource
    @group = group
    @current_tab = current_tab
    @tabs = group.items
    @view = view
    @style = style
  end

  def tab_path(tab)
    if is_edit?
      helpers.edit_resource_path(resource: @resource, model: @resource.model, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    elsif is_new?
      helpers.new_resource_path(resource: @resource, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    else
      helpers.resource_path(resource: @resource, model: @resource.model, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    end
  end

  def is_edit?
    @view.in?([:edit, :update])
  end

  def is_new?
    @view.in?([:new, :create])
  end

  def is_initial_load?
    params[:active_tab_name].blank?
  end

  # On initial load we want that each tab button to be the selected one.
  # We do that so we don't get the wrongly selected item for a quick brief when first switching from one panel to another.
  def selected?(tab)
    if is_initial_load?
      current_tab.name.to_s == tab.name.to_s
    else
      tab.name.to_s == active_tab_name.to_s
    end
  end

  # Goes through all items and removes the ones that are not supposed to be visible.
  # Example below:
  # tabs do
  #   field :comments, as: :has_many
  # end
  # Because the developer hasn't specified that it should be visible on edit views (with the show_on: :edit option),
  # the field should not be visible in the item switcher either.
  def visible_items
    tabs.select do |tab|
      next false if tab.items.blank?
      next false if tab.is_field? && !tab.authorized?
      next false if tab.has_a_single_item? && !single_item_visible?(tab.items.first)
      next false if !tab.visible?
      next false if !tab.visible_on?(view)

      true
    end
  end

  private

  def single_item_visible?(item)
    # Item is visible if is not a field or don't have its own panel
    return true if !item.is_field?
    return true if !item.has_own_panel?

    return false if !item.visible_on?(view)

    # If item is hydrated with the correct resource and is not authorized, it's not visible
    return false if item.resource.present? && !item.authorized?

    true
  end
end
