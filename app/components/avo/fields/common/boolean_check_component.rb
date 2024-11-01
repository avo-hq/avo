# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < Avo::BaseComponent
  prop :checked, default: false
  prop :size, default: :md
  prop :icon do |value|
    @checked ? "heroicons/outline/check-circle" : "heroicons/outline/x-circle"
  end

  def classes
    helpers.class_names({
      "h-5": @size == :sm,
      "h-6": @size == :md,
      "text-green-600": @checked,
      "text-red-600": !@checked,
    })
  end
end
