# frozen_string_literal: true

class Avo::UI::IconButtonComponent < Avo::BaseComponent
  prop :icon
  prop :action
  prop :classes
  prop :type, default: :button
  prop :data, default: {}.freeze

  def data
    {
      action: @action
    }.merge(@data)
  end

  def button_classes
    class_names(
      "inline-flex items-center justify-center rounded-md p-1 cursor-pointer",
      @classes
    )
  end
end
