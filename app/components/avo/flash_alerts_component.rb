# frozen_string_literal: true

class Avo::FlashAlertsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  def initialize(flashes: [])
    @flashes = flashes
  end
end
