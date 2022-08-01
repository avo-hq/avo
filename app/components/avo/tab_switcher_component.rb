# frozen_string_literal: true

class Avo::TabSwitcherComponent < Avo::BaseComponent
  include Avo::UrlHelpers
  include Avo::ApplicationHelper

  attr_reader :active_tab_name
  attr_reader :group
  attr_reader :current_tab
  attr_reader :tabs
  attr_reader :view

  def initialize(resource:, group:, current_tab:, active_tab_name:, view:)
    @active_tab_name = active_tab_name
    @resource = resource
    @group = group
    @current_tab = current_tab
    @tabs = group.items
    @view = view
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
    @view == :edit
  end

  def is_new?
    @view == :new
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
    tabs.select do |item|
      visible = true

      if item.items.blank?
        visible = false
      end

      first_item = item.items.first
      if item.items.count == 1 && first_item.is_field? && first_item.has_own_panel? && !first_item.visible_on?(view)
        # Return nil if tab contians a has_many type of fields and it's hidden in current view
        visible = false
      end

      if item.respond_to?(:visible_on?)
        visible = item.visible_on? view
      end

      if item.respond_to?(:visible?)
        visible = item.visible?
      end

      if item.respond_to?(:authorized?)
        visible = item.authorized?
      end

      visible
    end
  end
end
