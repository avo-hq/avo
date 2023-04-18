# frozen_string_literal: true

class Avo::Fields::Common::Files::ViewType::ListComponent < Avo::Fields::Common::Files::ViewType::GridComponent
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
