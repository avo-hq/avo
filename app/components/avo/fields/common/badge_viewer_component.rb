# frozen_string_literal: true

class Avo::Fields::Common::BadgeViewerComponent < ViewComponent::Base
  def initialize(value:, options:)
    @value = value
    @options = options
  end
end
