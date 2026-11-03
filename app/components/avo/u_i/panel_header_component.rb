# frozen_string_literal: true

class Avo::UI::PanelHeaderComponent < Avo::BaseComponent
  prop :title
  prop :description
  # Set when something outside the header rewrites the description later, e.g. a lazy index frame.
  # The element then always renders, empty when there is no description, so it can be targeted.
  prop :description_id
  prop :size, default: :md
  prop :url
  prop :target
  prop :index
  prop :class

  renders_one :before_title
  renders_one :title_content
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
