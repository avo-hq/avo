module Avo
  module TurboStreamActionsHelper
    def download(content:, filename:)
      turbo_stream_action_tag :download, content: content, filename: filename
    end

    def flash_alerts
      turbo_stream_action_tag :append, target: "alerts" do
        render Avo::FlashAlertsComponent.new flashes: flash.discard
      end
    end
  end
end

Turbo::Streams::TagBuilder.prepend(Avo::TurboStreamActionsHelper)
