# frozen_string_literal: true

class Avo::NavigationHeadingComponent < ViewComponent::Base
  def initialize(label: nil)
    @label = label
  end
end
