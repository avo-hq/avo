# frozen_string_literal: true

class Avo::Fields::Common::Files::ViewType::ListItemComponent < Avo::Fields::Common::Files::ViewType::GridItemComponent
  prop :field, Avo::Fields::BaseField
  prop :resource, Avo::BaseResource
  prop :file, _Nilable(ActiveStorage::Attachment)
  prop :extra_classes, _Nilable(String)

  def icon_for_file
    if is_image?
      "photo"
    elsif is_audio?
      "speaker-wave"
    elsif is_video?
      "video-camera"
    else
      "document"
    end
  end
end
