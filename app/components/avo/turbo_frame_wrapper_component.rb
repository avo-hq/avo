# frozen_string_literal: true

class Avo::TurboFrameWrapperComponent < Avo::BaseComponent
  prop :frame_id, kind: :positional

  def render_content
    return content if @frame_id.blank?

    turbo_frame_tag @frame_id  do
      # When rendering the frames the flashed content gets lost.
      # We're appending it back if it's a turbo_frame_request.
      if helpers.turbo_frame_request?
        helpers.turbo_stream_action_tag :append, target: "alerts", template: render(Avo::FlashAlertsComponent.new(flashes: helpers.flash))
      end

      content
    end
  end
end
