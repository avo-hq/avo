# frozen_string_literal: true

class Avo::FlashAlertsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :flashes, ActionDispatch::Flash::FlashHash, default: [].freeze
end
