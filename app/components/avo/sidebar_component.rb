# frozen_string_literal: true

class Avo::SidebarComponent < ViewComponent::Base
  def dashboards
    return [] if Avo::App.license.lacks_with_trial(:dashboards)

    Avo::App.get_dashboards(helpers._current_user)
  end

  def resources
    Avo::App.resources_navigation(helpers._current_user)
  end

  def tools
    return [] if Avo::App.license.lacks_with_trial(:custom_tools)

    Avo::App.get_sidebar_partials
  end
end
