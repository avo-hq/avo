# frozen_string_literal: true

class Avo::TurboFrameWrapperComponent < ViewComponent::Base
  # Refer: https://github.com/github/view_component/issues/1099
  # delegating `turbo_frame_tag` to helpers doesn't capture the
  # content in the block.
  include Turbo::FramesHelper

  attr_reader :args, :kwargs

  def initialize(*args, **kwargs)
    @args = args
    @kwargs = kwargs
  end
end
