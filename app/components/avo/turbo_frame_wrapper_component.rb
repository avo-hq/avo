# frozen_string_literal: true

class Avo::TurboFrameWrapperComponent < Avo::BaseComponent
  attr_reader :name

  def initialize(name = nil)
    @name = name
  end
end
