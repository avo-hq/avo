# frozen_string_literal: true

class Avo::Sidebar::ItemSwitcherComponent < Avo::Sidebar::BaseItemComponent
  def resource
    item.parsed_resource
  end

  def dashboard
    item.parsed_dashboard
  end

  def render?
    item.visible?
  end
end
