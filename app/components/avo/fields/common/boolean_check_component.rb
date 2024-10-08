# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < Avo::BaseComponent
  prop :checked, _Boolean, default: false
  prop :size, Symbol, default: :md
  prop :icon, _Nilable(String) do |value|
    @checked ? "heroicons/outline/check-circle" : "heroicons/outline/x-circle"
  end
  prop :classes, _Nilable(String)

  def classes
    helpers.class_names({
      "h-5": @size == :sm,
      "h-6": @size == :md,
      "text-green-600": @checked,
      "text-red-600": !@checked,
    })
  end
end
