# frozen_string_literal: true

class Avo::CardComponent < ViewComponent::Base
  def initialize(card: nil)
    @card = card
  end

  def render?
    !@card.nil?
  end
end
