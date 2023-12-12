# frozen_string_literal: true

class Avo::Fields::HasManyField::ShowComponent < Avo::Fields::ShowComponent
  include Turbo::FramesHelper

  def turbo_frame_loading = kwargs[:turbo_frame_loading]

  def loading
    turbo_frame_loading || params[:turbo_frame_loading] || "eager"
  end
end
