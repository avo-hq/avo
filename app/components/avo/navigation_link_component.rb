# frozen_string_literal: true

class Avo::NavigationLinkComponent < ViewComponent::Base
  def initialize(label: nil, path: nil, active: :inclusive, size: :md)
    @label = label
    @path = path
    @active = active
    @size = size
  end
end
