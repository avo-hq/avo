# frozen_string_literal: true

class Avo::UI::PopoverComponent < Avo::BaseComponent
  prop :class, default: ""
  prop :type, default: :simple
  prop :show_action_row, default: false
  prop :action_icon, default: "tabler/outline/plus"
  prop :action_label, default: "Menu item"
  prop :hidden, default: false
  prop :data, default: {}.freeze

  renders_one :body
  renders_one :action_row

  def simple?
    @type.to_sym == :simple
  end

  def complex?
    @type.to_sym == :complex
  end

  def show_action_row?
    complex? && @show_action_row
  end
end
