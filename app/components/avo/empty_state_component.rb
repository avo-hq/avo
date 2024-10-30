# frozen_string_literal: true

class Avo::EmptyStateComponent < Avo::BaseComponent
  prop :message
  prop :view_type, default: :table do |value|
    value&.to_sym
  end
  prop :add_background, default: false
  prop :by_association, default: false

  def text
    @message || locale_message
  end

  def view_type_svg
    "avo/#{@view_type}-empty-state"
  end

  private

  def locale_message
    helpers.t @by_association ? "avo.no_related_item_found" : "avo.no_item_found"
  end
end
