# frozen_string_literal: true

class Avo::TurboFrameWrapperComponent < Avo::BaseComponent
  prop :name, kind: :positional
  prop :class, kind: :positional

  # When rendering the frames the flashed content gets lost.
  # We're appending it back if it's a turbo_frame_request.
  def flash_content
    if helpers.turbo_frame_request?
      helpers.turbo_stream_action_tag :append, target: "alerts", template: render(Avo::FlashAlertsComponent.new(flashes: helpers.flash))
    end
  end
end
