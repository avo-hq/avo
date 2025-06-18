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
      {body: data[:body], timeout: data[:timeout]}
    else
      {body: data, timeout: nil}
    end
  end
end
