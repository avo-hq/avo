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
  # When true, the panel body becomes a Shift+T focus anchor: focusing it lets the
  # user Tab into the fields and Shift+Tab back to the controls in the header.
  prop :content_focusable, default: false

  renders_one :header
  renders_one :controls
  renders_one :cover
  renders_one :sidebar
  renders_many :pre_bodies
  renders_one :body
  renders_one :card, "Avo::UI::CardComponent" # wraps content into a card automatically
  renders_one :footer

  def content_focusable?
    @content_focusable
  end

  def has_cover?
    @cover.present?
  end

  def has_avatar?
    @avatar.present?
  end
end
