module Avo
  module Dashboards
    class ChartkickCard < BaseCard
      class_attribute :chart_type
      class_attribute :chart_options, default: {}
      class_attribute :flush, default: true
      class_attribute :legend, default: false
      class_attribute :scale, default: false
      class_attribute :legend_on_left, default: false
      class_attribute :legend_on_right, default: false

      def chartkick_classes
        case chart_type
        when :area_chart, :line_chart, :scatter_chart, :bar_chart, :column_chart
          if self.class.flush
            "-mx-1.5 top-auto -bottom-1.5"
          else
            "px-2"
          end
        else
          ""
        end
      end

      def chartkick_options
        card_height = 144
        card_heading = 40

        default = {
          # figure our the available height for the chart
          height: "#{(rows * card_height) - card_heading}px",
          colors: %w[#0B8AE2 #34C683 #2AB1EE #34C6A8],
          library: {
            discrete: false,
            points: false,
            animation: true
          },
          id: "#{dashboard.id}-#{rand(10_000..99_999)}"
        }

        no_scale_options = {display: false}
        no_scale = {
          library: {
            scales: {
              x: no_scale_options,
              y: no_scale_options
            }
          }
        }

        no_legend = {library: {plugins: {legend: {display: false}}}}
        legend_on_left = {library: {plugins: {legend: {position: "left"}}}}
        legend_on_right = {library: {plugins: {legend: {position: "right"}}}}

        # Add chart.js configuration for the different states
        unless self.class.legend
          default = default.deep_merge(no_legend)
        end

        unless self.class.scale
          default = default.deep_merge(no_scale)
        end

        if self.class.legend_on_left
          default = default.deep_merge(legend_on_left)
        end

        if self.class.legend_on_right
          default = default.deep_merge(legend_on_right)
        end

        # Add the custom chart options at the end
        default.deep_merge(self.class.chart_options)
      end
    end
  end
end
