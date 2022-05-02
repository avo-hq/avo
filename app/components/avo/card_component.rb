# frozen_string_literal: true

class Avo::CardComponent < ViewComponent::Base
  def initialize(card: nil)
    @card = card

    init_card
  end

  def render?
    !@card.nil?
  end

  def init_card
    if @card.respond_to? :query
      @card.query
    else
      @card.compute_result
    end
  end
end
