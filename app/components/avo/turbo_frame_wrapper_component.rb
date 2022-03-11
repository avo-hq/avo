# frozen_string_literal: true

class Avo::TurboFrameWrapperComponent < ViewComponent::Base
  attr_reader :name

  def initialize(name = nil)
    @name = name
  end
end
