# frozen_string_literal: true

class Avo::FlashAlertsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :flashes, default: {}.freeze do |flashes|
    flashes.to_h.deep_symbolize_keys.transform_values(&method(:parse))
  end

  private

  def parse(data)
    case data
    when Hash
      { body: data[:body], keep_open: data.fetch(:keep_open, false) }
    else
      { body: data, keep_open: false }
    end
  end
end
