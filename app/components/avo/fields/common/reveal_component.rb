# frozen_string_literal: true

class Avo::Fields::Common::RevealComponent < Avo::BaseComponent
  prop :field
  prop :view, reader: :public, default: Avo::ViewInquirer.new(:show).freeze

  delegate :show?, :index?, to: :view

  def mask
    @field.mask
  end

  def encoded_value
    @field.encoded_value
  end
end
