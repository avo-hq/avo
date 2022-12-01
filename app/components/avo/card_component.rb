# frozen_string_literal: true

class Avo::CardComponent < ViewComponent::Base
  attr_reader :card

  def initialize(card: nil)
    @card = card

    init_card
  end

  def render?
    card.present?
  end

  # Initializing the card byt running the query method.
  # We'll still keep the query block around for compatibility reasons.
  def init_card
    if card.respond_to? :query
      card.query
    elsif card.query_block.present?
      card.compute_result
    end
  end
end
