# frozen_string_literal: true

class Avo::SidebarComponent < ViewComponent::Base
  def dashboards
    Avo::App.get_dashboards(helpers._current_user)
  end

  def tools
    Avo::App.get_sidebar_partials
  end
end
