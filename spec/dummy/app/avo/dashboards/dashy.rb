class Dashy < Avo::Dashboards::BaseDashboard
  self.id = "dashy"
  self.name = "Dashy"
  self.description = "The first dashbaord"
  self.grid_cols = 3

  card UsersMetric
  card UserSignups
  card Scatter
  card MapCard
  card CustomPartial

  # card :Users_area,
  #      cols: 2,
  #      description: '',
  #      chart_type: :area_chart,
  #      query:
  #        Proc.new {
  #         #  abort [
  #         #   User.group_by_year(:birthday).count.map { |key, value| [key, value] },
  #         #   User.group_by_year(:birthday).count.map { |key, value| [key, value] }.shuffle
  #         #  ].inspect
  #          [
  #            {
  #              name: 'Users birthday',
  #              data: User.group_by_year(:birthday).count
  #            },
  #            {
  #              name: 'Other users',
  #              data: User.group_by_year(:birthday).count.map { |key, value| [key, rand(0..4)] }.to_h
  #            },
  #            {
  #              name: 'Some more users',
  #              data: User.group_by_year(:birthday).count.map { |key, value| [key, rand(0..3)] }.to_h
  #            }
  #          ]
  #        },
  #        chart_options: {
  #          library: {
  #            plugins: {
  #              legend: {
  #                display: false
  #              }
  #            }
  #          }
  #        }
  # card :Users_line,
  #      cols: 2,
  #      description: 'hehehe',
  #      chart_type: :line_chart,
  #      query: Proc.new { User.group_by_year(:birthday).count },
  #      chart_options: {
  #        library: {
  #          scales: {
  #            x: {
  #              display: true
  #            },
  #            y: {
  #              display: true
  #            }
  #          }
  #        }
  #      },
  #      omit_position_offset: true
  # card :Project_bar,
  #      cols: 1,
  #      description: '',
  #      chart_type: :bar_chart,
  #      query: Proc.new { Project.unscoped.group(:progress).count }
  # card :Users_scatter,
  #      cols: 3,
  #      description: '',
  #      chart_type: :scatter_chart,
  #      query: Proc.new { User.group_by_year(:birthday).count }
  # card :Projects_column,
  #      cols: 1,
  #      chart_type: :column_chart,
  #      query: Proc.new { Project.unscoped.group(:progress).count }

  # # card :Projects, cols: 3, chartkick: Proc.new { column_chart Project.unscoped.group(:progress).count, id: 'projects' }
  # card :Posts_pie,
  #      cols: 1,
  #      chart_type: :pie_chart,
  #      query: Proc.new { Post.group(:is_featured).count },
  #      refresh_every: 10.minutes

  # when :line_chart
  #   # default.merge(no_scales)
  # # when :pie_chart
  #   # default.merge(no_scales)
  # # when :column_chart
  #   # default.merge(no_scales)
  # when :bar_chart
  #   # default.merge(no_scales)
  # # when :area_chart
  #   # default.merge(no_scales)
  # when :scatter_chart

  # card :Metric,
  #      cols: 3,
  #      metric: ->(context:, range:, dashboard:, card:) {
  #        from = Date.today.midnight - 1.week
  #        to = Date.today.midnight

  #        if range.present?
  #          if range.to_s == range.to_i.to_s
  #            from = Date.today.midnight - range.to_i.days
  #            to = Date.today.midnight
  #          else
  #            case range
  #            when 'Today'
  #              from = Date.today.midnight - 1.day
  #              to = Date.today.midnight
  #            end
  #          end
  #        end

  #        Post.where(
  #          'created_at >= :from AND created_at < :to',
  #          from: from,
  #          to: to
  #        ).count
  #      },
  #      range: 30,
  #      ranges: [7, 30, 60, 365, 'Today', 'YTD']
  # card :posts, cols: 2, metric: 75, suffix: '%'
  # card :posts_2, label: 'New posts', cols: 2, metric: 12, prefix: '$'
end
