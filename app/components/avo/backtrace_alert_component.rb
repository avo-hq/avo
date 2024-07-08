# frozen_string_literal: true

class Avo::BacktraceAlertComponent < ViewComponent::Base
  include Avo::ApplicationHelper

  def initialize(backtrace: nil)
    @backtrace = backtrace
  end

  def render?
    @backtrace.present?
  end
end
