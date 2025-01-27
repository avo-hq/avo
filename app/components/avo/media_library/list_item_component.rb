# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ListItemComponent < Avo::BaseComponent
      with_collection_parameter :attachment

      prop :attachment, reader: :public
      prop :display_filename, default: true
      prop :attaching, default: false
      prop :multiple, default: false

      def data
        {
          component: component_name,
          attachment_id: attachment.id,
          media_library_attachment_param: attachment.as_json,
          media_library_blob_param: attachment.blob.as_json,
          media_library_path_param: helpers.main_app.url_for(attachment),
          media_library_attaching_param: @attaching,
          media_library_multiple_param: @multiple,
          media_library_selected_item: params[:controller_selector],
          action: 'click->media-library#selectItem',
        }.tap do |result|
          if @attaching
            result[:turbo_frame] = Avo::MEDIA_LIBRARY_ITEM_DETAILS_FRAME_ID
            result[:turbo_prefetch] = false
          else
            result[:turbo_prefetch] = true
          end
        end
      end
    end
  end
end
