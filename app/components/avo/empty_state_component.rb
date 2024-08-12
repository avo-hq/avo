# frozen_string_literal: true

class Avo::EmptyStateComponent < Avo::BaseComponent
  attr_reader :message, :view_type, :add_background, :by_association

  prop :message, _Nilable(String)
  prop :view_type, Symbol, default: :table do |value|
    value&.to_sym
  end
  prop :add_background, _Boolean, default: false
  prop :by_association, _Boolean, default: false

  def text
    message || locale_message
  end

  def view_type_svg
    "avo/#{view_type}-empty-state"
  end

  private

  def locale_message
    helpers.t by_association ? "avo.no_related_item_found" : "avo.no_item_found"
  end
end
