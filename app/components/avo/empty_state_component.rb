# frozen_string_literal: true

class Avo::EmptyStateComponent < ViewComponent::Base
  attr_reader :message, :view_type, :add_background, :by_association

  def initialize(message: nil, view_type: :table, add_background: false, by_association: false)
    @message = message
    @view_type = view_type
    @add_background = add_background
    @by_association = by_association
  end

  def text
    message || locale_message
  end

  def view_type_svg
    "#{view_type}-empty-state"
  end

  private

  def locale_message
    helpers.t by_association ? "avo.no_related_item_found" : "avo.no_item_found"
  end
end
