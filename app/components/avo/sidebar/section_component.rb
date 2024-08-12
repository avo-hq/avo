# frozen_string_literal: true

class Avo::Sidebar::SectionComponent < Avo::Sidebar::BaseItemComponent
  def render?
    super && items.any? { |group| group.items.find(&:visible?) }
  end

  def icon
    return nil if item.icon.nil?

    item.icon
  end
end
