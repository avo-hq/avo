# frozen_string_literal: true

class Avo::FlashAlertsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :flashes, Enumerable, default: -> { [] }
end
