# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < Avo::BaseComponent
  STATE_CONFIG = {
    true => {
      name: "checked",
      icon: "heroicons/outline/check-circle",
      color: "text-green-600"
    },
    false => {
      name: "unchecked",
      icon: "heroicons/outline/x-circle",
      color: "text-red-600"
    },
    nil => {
      name: "indeterminate",
      icon: "heroicons/outline/minus-circle",
      color: "text-gray-400"
    }
  }.freeze

  prop :checked, default: nil
  prop :size, default: :md
  prop :icon do
    STATE_CONFIG[@checked][:icon]
  end

  def state
    STATE_CONFIG[@checked][:name]
  end

  def classes
    helpers.class_names({
      "h-5": @size == :sm,
      "h-6": @size == :md,
      STATE_CONFIG[@checked][:color] => true
    })
  end
end
