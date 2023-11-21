# frozen_string_literal: true

class Avo::TabSwitcherComponent < Avo::BaseComponent
  include Avo::UrlHelpers
  include Avo::ApplicationHelper

  attr_reader :active_tab_name
  attr_reader :group
  attr_reader :current_tab
  attr_reader :tabs
  attr_reader :view

  delegate :white_panel_classes, to: :helpers

  def initialize(resource:, group:, current_tab:, active_tab_name:, view:)
    @active_tab_name = active_tab_name
    @resource = resource
    @group = group
    @current_tab = current_tab
    @tabs = group.items
    @view = view
  end

  #TOD: helper to record:
  def tab_path(tab)
    if is_edit?
      helpers.edit_resource_path(resource: @resource, record: @resource.record, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    elsif is_new?
      helpers.new_resource_path(resource: @resource, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    else
      helpers.resource_path(resource: @resource, record: @resource.record, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    end
  end

  def is_edit?
    @view.in?(%w[edit update])
  end

  def is_new?
    @view.in?(%w[new create])
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
end
