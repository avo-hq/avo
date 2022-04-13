# frozen_string_literal: true

class Avo::Sidebar::ItemComponent < ViewComponent::Base
  def initialize(label: nil, path: nil, active: :inclusive, target: nil)
    @label = label
    @path = path
    @active = active
    @target = target
  end

  def is_external?
    URI(@path).scheme.present?
  end

  # For external links active_link_to marks them all as active.
  def link_method
    is_external? ? :link_to : :active_link_to
  end
end
