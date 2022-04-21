# frozen_string_literal: true

class Avo::CardsListComponent < ViewComponent::Base
  attr_reader :parent

  def initialize(parent: nil)
    @parent = parent
  end

  def render?
    parent.cards.present?
  end
end
