# frozen_string_literal: true

class Avo::UI::PillComponent < Avo::BaseComponent
  prop :icon, default: "tabler/outline/adjustments-horizontal"
  prop :label
  prop :selected, default: false
  prop :disabled, default: false
  prop :icon_only, default: false
  prop :counter
  prop :filter_key
  prop :filter_value
  prop :data
  prop :classes

  def selected? = @selected
  def disabled? = @disabled
  def icon_only? = @icon_only
  def show_details? = selected? && (@counter.present? || @filter_key.present?)
end
