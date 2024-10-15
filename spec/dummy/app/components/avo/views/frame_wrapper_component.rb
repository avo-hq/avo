# frozen_string_literal: true

class Avo::Views::FrameWrapperComponent < Avo::Views::ResourceIndexComponent
  def initialize(**args)
    @args = args
  end
end
