# frozen_string_literal: true

class Avo::ModalComponent < Avo::BaseComponent
  renders_one :heading
  renders_one :controls

  prop :width, default: :xl # :sm, :md, :lg, :xl, :2xl, :3xl, :4xl, :full
  prop :height, default: :auto # :auto, :sm, :md, :lg, :xl, :2xl, :3xl, :4xl, :full
  prop :body_class
  prop :overflow, default: :auto
  prop :close_modal_on_backdrop_click, default: true, reader: :public
  prop :title
  prop :description
  prop :show_close_button, default: true

  def height_classes
    "max-h-[calc(100dvh-5rem)] min-h-1/4"
  end

  def has_header?
    @title.present? || @description.present? || heading? || @show_close_button
  end
end
