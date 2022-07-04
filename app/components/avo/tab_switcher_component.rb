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

  # Goes through all items and removes the ones that are not supposed to be visible.
  # Example below:
  # tabs do
  #   field :comments, as: :has_many
  # end
  # Because the developer hasn't specified that it should be visible on edit views (with the show_on: :edit option),
  # the field should not be visible in the item switcher either.
  def visible_items
    tabs.map do |tab|
      first_item = tab.items.first

      if tab.items.blank?
        # Return nil if tab group is empty
        nil
      elsif tab.items.count == 1 && first_item.is_field? && first_item.has_own_panel? && !first_item.visible_on?(view)
        # Return nil if tab contians a has_many type of fields and it's hidden in current view
        nil
      else
        tab
      end
    end
    .compact
    .select do |item|
      visible = true

      if item.respond_to?(:visible_on?)
        visible = item.visible_on? view
      end

      if item.respond_to?(:visible?)
        visible = item.visible?
      end

      visible
    end
  end
end
