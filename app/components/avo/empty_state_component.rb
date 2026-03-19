# frozen_string_literal: true

class Avo::EmptyStateComponent < Avo::BaseComponent
  prop :message
  prop :by_association, default: false
  prop :classes

  def text
    @message || locale_message
  end

  def cards
    [
      {number: 1, position: :top, title: :large},
      {number: 2, position: :middle, title: :large},
      {number: 3, position: :bottom, title: :large}
    ]
  end

  private

  def locale_message
    helpers.t @by_association ? "avo.no_related_item_found" : "avo.no_item_found"
  end
end
