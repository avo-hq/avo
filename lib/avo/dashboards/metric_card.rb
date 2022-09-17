module Avo
  module Dashboards
    class MetricCard < BaseCard
      class_attribute :prefix
      class_attribute :suffix
      # @todo: transform 1234 to 1.2K
    end
  end
end
