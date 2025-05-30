# frozen_string_literal: true

class Avo::TabSwitcherComponent < Avo::BaseComponent
  include Avo::URLHelpers
  include Avo::ApplicationHelper

  delegate :white_panel_classes, to: :helpers
  delegate :group_param, to: :@group

  prop :resource
  prop :group
  prop :current_tab
  prop :active_tab_name, reader: :public
  prop :view

  #TOD: helper to record:
  def tab_path(tab)
    if is_edit?
      helpers.edit_resource_path(resource: @resource, record: @resource.record, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: @group.turbo_frame_id)
    elsif is_new?
      helpers.new_resource_path(resource: @resource, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: @group.turbo_frame_id)
    else
      helpers.resource_path(resource: @resource, record: @resource.record, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: @group.turbo_frame_id)
    end
  end

  def is_edit?
    @view.in?(%w[edit update])
  end

  def is_new?
    @view.in?(%w[new create])
  end

  # We'll mark the tab as selected if it's the current one
  def current_one?(tab)
    tab.name == @active_tab_name
  end

  private

  def tab_param_missing?
    params[group_param].blank?
  end
end
