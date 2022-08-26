# frozen_string_literal: true

class Avo::FlashAlertsComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  ALERT_TYPES = [:error, :alert, :success, :notice, :info, :warning]

  def initialize(flashes: [])
    @flashes = flashes
  end

  def flashes
    @flashes.select do |type, message|
      type.to_sym.in?(ALERT_TYPES)
    end
  end
end
