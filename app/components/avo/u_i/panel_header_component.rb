# frozen_string_literal: true

class Avo::UI::PanelHeaderComponent < Avo::BaseComponent
  prop :title
  prop :description
  prop :size, default: :md
  prop :url
  prop :target
  prop :index
  prop :class

  renders_one :title_slot
  renders_one :avatar
  renders_one :controls
  renders_one :discreet_information

  def size_md?
    @size == :md
  end

  def size_sm?
    @size == :sm
  end
end
