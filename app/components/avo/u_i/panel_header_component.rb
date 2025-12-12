# frozen_string_literal: true

class Avo::UI::PanelHeaderComponent < Avo::BaseComponent
  prop :title
  prop :description
  prop :size, default: :medium
  prop :url
  prop :target
  prop :index

  renders_one :title_slot
  renders_one :avatar
  renders_one :profile_photo
  renders_one :controls
  renders_one :discreet_information

  def size_medium?
    @size == :medium
  end

  def size_small?
    @size == :small
  end
end
