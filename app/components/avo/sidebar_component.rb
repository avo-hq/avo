# frozen_string_literal: true

class Avo::SidebarComponent < ViewComponent::Base
  def initialize(sidebar_open: nil, for_mobile: false)
    @sidebar_open = sidebar_open
    @for_mobile = for_mobile
  end

  def dashboards
    return [] unless Avo.plugin_manager.installed?("avo-dashboards")

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
