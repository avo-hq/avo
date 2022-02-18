# frozen_string_literal: true

class Avo::NavigationLinkComponent < ViewComponent::Base
  attr_reader :label
  attr_reader :path
  attr_reader :active
  attr_reader :size

  def initialize(label: nil, path: nil, active: :inclusive, size: :md)
    @label = label
    @path = path
    @active = active
    @size = size
  end
end
