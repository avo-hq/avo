# frozen_string_literal: true

class Avo::Fields::Common::HeadingComponent < ViewComponent::Base
  attr_reader :value
  attr_reader :as_html

  def initialize(value:, as_html:)
    @value = value
    @as_html = as_html
  end
end
