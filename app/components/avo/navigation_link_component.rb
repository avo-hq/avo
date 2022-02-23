# frozen_string_literal: true

class Avo::NavigationLinkComponent < ViewComponent::Base
  def initialize(label: nil, path: nil, active: :inclusive, size: :md, target: nil)
    @label = label
    @path = path
    @active = active
    @size = size
    @target = target
  end
end
