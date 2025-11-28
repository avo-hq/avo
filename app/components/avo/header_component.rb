# frozen_string_literal: true

class Avo::HeaderComponent < Avo::BaseComponent
  prop :title
  prop :description
  prop :size, default: :medium
  prop :show_avatar, default: true
  prop :show_description, default: true
  prop :url
  prop :target

  renders_one :title_slot
  renders_one :avatar
  renders_one :controls
  renders_one :discreet_information

  def size_medium?
    @size == :medium
  end

  def size_small?
    @size == :small
  end
end
