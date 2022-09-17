# frozen_string_literal: true

class Avo::Fields::Common::BooleanCheckComponent < ViewComponent::Base
  def initialize(checked: false)
    @checked = checked
  end
end
