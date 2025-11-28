# frozen_string_literal: true

class Avo::DetailViewComponent < Avo::BaseComponent
  prop :floating_sidebar, default: false
  prop :full_width, default: false
  prop :class, default: ""
  prop :profile_photo
  prop :cover_photo
  prop :data, default: -> { {}.freeze }
  prop :class

  renders_one :header
  renders_one :breadcrumbs
  renders_one :sidebar
  renders_one :body

  def floating_sidebar?
    @floating_sidebar
  end

  def full_width?
    @full_width
  end
end
