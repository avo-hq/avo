module Avo
  module Dashboards
    class MetricCard < BaseCard
      class_attribute :prefix
      class_attribute :suffix

      def computed_value(range:)
        query context: Avo::App.context,
          dashboard: dashboard,
          card: self,
          range: range
      end
    end
  end
end
