# frozen_string_literal: true

class Avo::Fields::Common::Files::ViewType::ListComponent < Avo::Fields::Common::Files::ViewType::GridComponent
  def render_icon
    helpers.svg icon_for_file, class: "h-5 text-gray-600"
  end

  private

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
