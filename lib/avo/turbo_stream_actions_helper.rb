module Avo
  module TurboStreamActionsHelper
    def avo_download(content:, filename:)
      turbo_stream_action_tag :download, content: content, filename: filename
    end

    def avo_flash_alerts
      turbo_stream_action_tag :append,
        target: "alerts",
        template: @view_context.render(Avo::FlashAlertsComponent.new(flashes: @view_context.flash.discard))
    end

    def avo_close_modal
      turbo_stream_action_tag :replace,
        target: Avo::MODAL_FRAME_ID,
        template: @view_context.turbo_frame_tag(Avo::MODAL_FRAME_ID)
    end

    def avo_turbo_reload
      turbo_stream_action_tag :turbo_reload
    end

    # `target_name` and `frame_id` narrow the update to the field that opened the dialog: the input's name,
    # and the frame the dialog was opened in. Without them every field for `relation_name` is updated.
    def avo_update_belongs_to(relation_name:, target_record_id:, target_resource_label:, target_resource_class:, target_name: nil, frame_id: nil)
      turbo_stream_action_tag "update-belongs-to",
        data: {
          relation_name: relation_name,
          target_name: target_name,
          frame_id: frame_id,
          target_record_id: target_record_id,
          target_resource_label: target_resource_label,
          target_resource_class: target_resource_class
        }.compact
    end
  end
end
