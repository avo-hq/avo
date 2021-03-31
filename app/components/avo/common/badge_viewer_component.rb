# frozen_string_literal: true

class Avo::Common::BadgeViewerComponent < ViewComponent::Base
  def initialize(value:, options:)
    @value = value
    @options = options
  end
end
