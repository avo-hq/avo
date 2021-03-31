# frozen_string_literal: true

class Avo::Common::BooleanCheckComponent < ViewComponent::Base
  def initialize(checked: false)
    @checked = checked
  end
end
