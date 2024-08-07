# frozen_string_literal: true

class Avo::BacktraceAlertComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :backtrace, _Nilable(Array)

  def render?
    @backtrace.present?
  end
end
