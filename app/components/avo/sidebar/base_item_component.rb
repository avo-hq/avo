# frozen_string_literal: true

class Avo::Sidebar::BaseItemComponent < Avo::BaseComponent
  delegate :collapsable, :collapsed, to: :@item

  prop :item, reader: :public
  prop :locals, default: {}.freeze

  def after_initialize
    @items = @item.items.select(&:visible?)
  end

  def render?
    @items.any?
  end

  def key
    result = "avo.#{request.host}.main_menu.#{@item.name.to_s.underscore}"

    if @item.icon.present?
      result += ".#{@item.icon.parameterize.underscore}"
    end

    result
  end

  def data
    result = {}
    if collapsable
      result[:controller] = "menu"
      result[:menu_target] = "self"
      result[:menu_key_param] = key
      result[:menu_default_collapsed_state] = collapsed ? "collapsed" : "expanded"
    end
    result
  end
end
