# frozen_string_literal: true

class Avo::Fields::Common::HeadingComponent < ViewComponent::Base
  attr_reader :value
  attr_reader :as_html
  attr_reader :empty

  def initialize(value:, as_html:, empty:)
    @value = value
    @as_html = as_html
    @empty = empty
  end
end
