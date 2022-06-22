# frozen_string_literal: true

class Avo::TabSwitcherComponent < Avo::BaseComponent
  include Avo::UrlHelpers
  include Avo::ApplicationHelper

  attr_reader :active_tab_name
  attr_reader :group
  attr_reader :tabs
  attr_reader :view

  def initialize(resource:, group:, tabs:, active_tab_name:, view:)
    @active_tab_name = active_tab_name
    @resource = resource
    @group = group
    @tabs = tabs
    @view = view
  end

  def tab_path(tab)
    if is_edit?
      helpers.edit_resource_path(resource: @resource, model: @resource.model, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    else
      helpers.resource_path(resource: @resource, model: @resource.model, keep_query_params: true, active_tab_name: tab.name, tab_turbo_frame: group.turbo_frame_id)
    end
  end

  def is_edit?
    @view == :edit
  end
end
