class LineChart < Avo::Dashboards::ChartkickCard
  self.id = "line_chart"
  self.label = "Line chart"
  self.chart_type = :line_chart

  def query(context:, range:, dashboard:, card:)
    [
      {
        name: "batch 1",
        data: 17.times.map { |i| [i + 1, Random.rand(32)] }
      },
      {
        name: "batch 1",
        data: 17.times.map { |i| [i + 1, Random.rand(32)] }
      },
      {
        name: "batch 1",
        data: 17.times.map { |i| [i + 1, Random.rand(32)] }
      }
    ]
  end

  def chartkick_classes
    case chart_type
    when :area_chart, :line_chart
      # , :scatter_chart
      # unless omit_position_offset
      # end
      "-mx-1.5 relative top-auto -bottom-1.5"
    when :pie_chart
      return "relative bottom-1" unless omit_position_offset
    # when :column_chart, :bar_chart
    else
      ""
    end
  end

  def chartkick_options
    scale = {
      active: false,
      display: true,
      paddingLeft: 0,
      paddingRight: 0,
      right: 0,
      left: 0,
      afterFit: "() => { console.log('afterIFt')}"
    }
    no_scales = {
      library: {
        layout: {
          padding: 0,
          autoPadding: true
        },
        scales: {
          x: {
            **scale,
            # this needs to be addressed
            min: 1,
            max: 17,
          },
          y: scale
        },
        defaults: {}
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
