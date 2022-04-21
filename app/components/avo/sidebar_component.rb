# frozen_string_literal: true

class Avo::SidebarComponent < ViewComponent::Base
  def dashboards
    Avo::App.dashboards_for_navigation
  end

  def resources
    Avo::App.resources_for_navigation
  end

  def tools
    Avo::App.tools_for_navigation
  end
end
