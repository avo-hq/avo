# frozen_string_literal: true

class Avo::BacktraceAlertComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :backtrace

  def render?
    @backtrace.present?
  end
end
