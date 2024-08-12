# frozen_string_literal: true

class Avo::Sidebar::SectionComponent < Avo::Sidebar::BaseItemComponent
  def render?
    items.any? do |item| 
      if item.is_a? Avo::Menu::Group
        item.items.find(&:visible?)
      else
        true
      end
    end
  end

  def icon
    return nil if item.icon.nil?

    item.icon
  end

  private

  def groups
    items.select {|item| item.is_a? Avo::Menu::Group}
  end
end
