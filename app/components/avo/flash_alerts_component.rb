# frozen_string_literal: true

class Avo::FlashAlertsComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(flashes: [])
    @flashes = flashes
  end
end
