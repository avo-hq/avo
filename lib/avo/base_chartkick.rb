module Avo
  class BaseChartkick < BaseCard
    class_attribute :chart_type
    class_attribute :chart_options, default: {}
    class_attribute :omit_position_offset, default: false

    def chartkick_classes
      case chart_type
      when :area_chart, :line_chart, :scatter_chart
        unless @omit_position_offset
          return '-mx-1.5 relative top-auto -bottom-1.5'
        end
      when :pie_chart
        return 'relative bottom-1' unless @omit_position_offset
      when :column_chart, :bar_chart, ''
      else
        ''
      end
    end

    def chartkick_options
      default = {
        height: '100px',
        colors: %w[#0B8AE2 #34C683 #2AB1EE #34C6A8],
        library: {
          discrete: false,
          points: false,
          animation: true
        },
        id: "#{dashboard.id}-#{rand(10_000..99_999)}"
      }

      'mx-[-20px] mb-[-20px]'

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

      case chart_type
      when :line_chart
        default.deep_merge(no_scales).deep_merge(self.class.chart_options)
      when :pie_chart
        default
          .deep_merge(
            { library: { plugins: { legend: { position: 'right' } } } }
          )
          .deep_merge(no_scales)
          .deep_merge(self.class.chart_options)
      when :column_chart
        default.deep_merge(no_scales).deep_merge(self.class.chart_options)
      when :bar_chart
        default.deep_merge(no_scales).deep_merge(self.class.chart_options)
      when :area_chart
        default.deep_merge(no_scales).deep_merge(self.class.chart_options)
      when :scatter_chart
        default.deep_merge(no_scales).deep_merge(self.class.chart_options)
      else
        default.deep_merge(self.class.chart_options)
      end
    end
  end
end
