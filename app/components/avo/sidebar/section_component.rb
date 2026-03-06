# frozen_string_literal: true

class Avo::Sidebar::SectionComponent < Avo::Sidebar::BaseItemComponent
  def icon
    item.icon if item.icon.present?
  end
end
