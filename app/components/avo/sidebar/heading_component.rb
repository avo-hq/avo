# frozen_string_literal: true

class Avo::Sidebar::HeadingComponent < ViewComponent::Base
  attr_reader :collapsable
  attr_reader :icon
  attr_reader :key
  attr_reader :label

  def initialize(label: nil, icon: nil, collapsable: false, key: nil)
    @collapsable = collapsable
    @icon = icon
    @key = key
    @label = label
  end
end
