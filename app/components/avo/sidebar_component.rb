# frozen_string_literal: true

class Avo::SidebarComponent < Avo::BaseComponent
  prop :sidebar_open, _Boolean, default: false
  prop :for_mobile, _Boolean, default: false

  def dashboards
    return [] unless Avo.plugin_manager.installed?(:avo_dashboards)

    Avo::Dashboards.dashboard_manager.dashboards_for_navigation
  end

  def resources
    Avo.resource_manager.resources_for_navigation helpers._current_user
  end

  def tools
    Avo.tool_manager.tools_for_navigation
  end

  def stimulus_target
    @for_mobile ? "mobileSidebar" : "sidebar"
  end
end
