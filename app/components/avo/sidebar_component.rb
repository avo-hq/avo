# frozen_string_literal: true

class Avo::SidebarComponent < ViewComponent::Base
  def initialize(sidebar_open: nil, for_mobile: false)
    @sidebar_open = sidebar_open
    @for_mobile = for_mobile
  end

  def dashboards
    Avo::App.dashboards_for_navigation
  end

  def resources
    Avo::App.resources_for_navigation
  end

  def tools
    Avo::App.tools_for_navigation
  end

  def stimulus_target
    @for_mobile ? "mobileSidebar" : "sidebar"
  end
end
