# frozen_string_literal: true

class Avo::UI::PanelComponent < Avo::BaseComponent
  prop :title, reader: :public
  prop :description, reader: :public
  prop :external_link
  prop :args, kind: :**, default: {}.freeze
  prop :avatar
  prop :cover
  prop :class
  prop :index
  prop :data, default: -> { {}.freeze }

  renders_one :header
  renders_one :controls
  renders_one :cover
  renders_one :sidebar
  renders_one :body
  renders_one :card, "Avo::UI::CardComponent" # wraps content into a card automatically
  renders_one :footer

  def has_cover?
    @cover.present?
  end

  def has_avatar?
    @avatar.present?
  end
end
