# frozen_string_literal: true

module Avo
  module MediaLibrary
    class ListItemComponent < Avo::BaseComponent
      with_collection_parameter :blob

      prop :blob, reader: :public
      prop :display_filename, default: true
      prop :attaching, default: false
      prop :multiple, default: false

      def data
        {
          component: component_name,
          blob_id: blob.id,
          media_library_blob_param: blob.as_json,
          media_library_path_param: helpers.main_app.url_for(blob),
          media_library_attaching_param: @attaching,
          media_library_multiple_param: @multiple,
          media_library_selected_item: params[:controller_selector],
          action: "click->media-library#selectItem"
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
