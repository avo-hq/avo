# frozen_string_literal: true

class Avo::Dashboards::DividerComponent < ViewComponent::Base
  attr_reader :divider

  delegate :label, to: :divider

  def initialize(divider: nil)
    @divider = divider
  end

  def render?
    @divider.present?
  end

  def invisible?
    @divider.invisible
  end
end
