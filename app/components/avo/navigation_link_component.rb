# frozen_string_literal: true

class Avo::NavigationLinkComponent < ViewComponent::Base
  def initialize(label: nil, path: nil, active: :inclusive, target: nil)
    @label = label
    @path = path
    @active = active
    @target = target
  end
end
