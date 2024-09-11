# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < Avo::BaseComponent
  prop :checked, _Boolean, default: false
  prop :icon, _Nilable(String) do |value|
    @checked ? "heroicons/outline/check-circle" : "heroicons/outline/x-circle"
  end
  prop :classes, _Nilable(String) do |value|
    "h-6 #{@checked ? "text-green-600" : "text-red-500"}"
  end
end
