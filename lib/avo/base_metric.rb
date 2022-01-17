module Avo
  class BaseMetric < BaseCard
    class_attribute :prefix
    class_attribute :suffix

    def computed_value(range:)
      value context: Avo::App.context,
            dashboard: dashboard,
            card: self,
            range: range
    end
  end
end
