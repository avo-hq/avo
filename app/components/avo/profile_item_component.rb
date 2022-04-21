# frozen_string_literal: true

class Avo::ProfileItemComponent < ViewComponent::Base
  attr_reader :label
  attr_reader :icon
  attr_reader :path
  attr_reader :active
  attr_reader :target

  def initialize(label: nil, icon: nil, path: nil, active: :inclusive, target: nil)
    @label = label
    @icon = icon
    @path = path
    @active = active
    @target = target
  end
end
