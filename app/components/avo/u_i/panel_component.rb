# frozen_string_literal: true

class Avo::UI::PanelComponent < Avo::BaseComponent
  prop :external_link
  prop :args, kind: :**, default: {}.freeze
  prop :profile_photo
  prop :cover_photo
  prop :class
  prop :index
  prop :data, default: -> { {}.freeze }

  renders_one :header
  renders_one :controls
  renders_one :cover_photo
  renders_one :sidebar
  renders_one :body
  renders_one :footer

  def floating_sidebar?
    @floating_sidebar
  end

  def full_width?
    @full_width
  end

  def has_cover_photo?
    @cover_photo.present?
  end

  def has_profile_photo?
    @profile_photo.present?
  end
end
