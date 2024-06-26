# frozen_string_literal: true

class Avo::EmptyStateComponent < Avo::BaseComponent
  VIEW_TYPE = _Union(:map, :table, :grid)

  prop :message, _Nilable(String), reader: :public
  prop :view_type, VIEW_TYPE, default: :table, reader: :public, &:to_sym
  prop :add_background, _Boolean, default: false, reader: :public
  prop :by_association, _Boolean, default: false, reader: :public

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
