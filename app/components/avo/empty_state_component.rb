# frozen_string_literal: true

class Avo::EmptyStateComponent < Avo::BaseComponent
  prop :message
  prop :by_association, default: false

  def text
    @message || locale_message
  end

  private

  def locale_message
    helpers.t @by_association ? "avo.no_related_item_found" : "avo.no_item_found"
  end
end
