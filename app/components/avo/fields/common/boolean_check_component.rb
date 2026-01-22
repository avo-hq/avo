# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < Avo::BaseComponent
  STATE_CONFIG = {
    true => {
      name: "checked",
      icon: "tabler/outline/circle-check",
      color: "text-green-600"
    },
    false => {
      name: "unchecked",
      icon: "tabler/outline/circle-x",
      color: "text-red-600"
    },
    nil => {
      name: "indeterminate",
      icon: "tabler/outline/circle-minus",
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
    helpers.class_names(STATE_CONFIG[@checked][:color], {
      "h-5": @size == :sm,
      "h-6": @size == :md,
    })
  end
end
