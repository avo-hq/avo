# frozen_string_literal: true

class Avo::Sidebar::SectionComponent < Avo::Sidebar::BaseItemComponent
  def icon
    return nil if item.icon.nil?

    item.icon
  end
end
