# frozen_string_literal: true

class Avo::ProfileItemComponent < ViewComponent::Base
  def initialize(label: nil, icon: nil, path: nil, active: :inclusive, target: nil)
    @label = label
    @icon = icon
    @path = path
    @active = active
    @target = target
  end
end
