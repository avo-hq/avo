# frozen_string_literal: true

class Avo::Fields::Common::StatusViewerComponent < ViewComponent::Base
  def initialize(status:, label:)
    @status = status
    @label = label
  end
end
