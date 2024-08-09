# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < Avo::BaseComponent
  prop :checked, _Boolean, default: false

  def after_initialize
    @icon = @checked ? "heroicons/outline/check-circle" : "heroicons/outline/x-circle"
    @classes = "h-6 #{@checked ? "text-green-600" : "text-red-500"}"
  end
end
