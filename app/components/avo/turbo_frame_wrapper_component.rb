# frozen_string_literal: true

class Avo::TurboFrameWrapperComponent < ViewComponent::Base
  attr_reader :name
  attr_reader :target

  def initialize(name = nil, target: nil)
    @name = name
    @target = target
  end
end
