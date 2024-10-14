# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < Avo::BaseComponent
  prop :checked, default: false
  prop :icon do |value|
    @checked ? "heroicons/outline/check-circle" : "heroicons/outline/x-circle"
  end
  prop :classes do |value|
    "h-6 #{@checked ? "text-green-600" : "text-red-500"}"
  end
end
