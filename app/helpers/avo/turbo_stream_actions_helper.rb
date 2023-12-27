module Avo
  module TurboStreamActionsHelper
    def download(content:, filename:)
      turbo_stream_action_tag :download, content: content, filename: filename
    end

    def flash_alerts
      turbo_stream_action_tag :append,
        target: "alerts",
        template: @view_context.render(Avo::FlashAlertsComponent.new(flashes: @view_context.flash.discard))
    end
  end
end

Turbo::Streams::TagBuilder.prepend(Avo::TurboStreamActionsHelper)
