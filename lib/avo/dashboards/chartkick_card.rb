module Avo
  module Dashboards
    class ChartkickCard < BaseCard
      class_attribute :chart_type
      class_attribute :chart_options, default: {}
      class_attribute :omit_position_offset, default: false

      def chartkick_classes
        case chart_type
        when :area_chart, :line_chart
          # , :scatter_chart
          unless omit_position_offset
            "-mx-1.5 relative top-auto -bottom-1.5"
          end
        when :pie_chart
          return "relative bottom-1" unless omit_position_offset
        # when :column_chart, :bar_chart
        else
          ""
        end
      end

      def chartkick_options
        no_scales = {
          library: {
            layout: {
              padding: 0
            },
            scales: {
              x: {
                display: false
              },
              y: {
                display: false
              }
            }
          }
        }

        default =
          {
            height: "100px",
            colors: %w[#0B8AE2 #34C683 #2AB1EE #34C6A8],
            library: {
              discrete: false,
              points: false,
              animation: true
            },
            id: "#{dashboard.id}-#{rand(10_000..99_999)}"
          }

        no_legend = {library: {plugins: {legend: {display: false}}}}
        legend_on_the_left = {library: {plugins: {position: "right"}}}

        # Go through each chart type and add the default options
        case chart_type
        when :line_chart
          default = default.deep_merge(no_legend).deep_merge(no_scales)
        when :pie_chart
          default = default.deep_merge(legend_on_the_left)
        when :column_chart
          default = default.deep_merge(no_legend).deep_merge(no_scales)
        when :bar_chart
          default = default.deep_merge(no_legend).deep_merge(no_scales)
        when :area_chart
          default = default.deep_merge(no_legend).deep_merge(no_scales)
        when :scatter_chart
          default = default.deep_merge(no_legend)
        end

        # Add the chart options at the end
        default.deep_merge(self.class.chart_options)
      end
    end
  end
end
