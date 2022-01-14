Chartkick.options = {
  height: '100px',
  colors: %w[#0B8AE2 #34C683 #2AB1EE #34C6A8],
  library: {
    discrete: false,
    points: false,
    animation: true,
    scales: {
      x: {
        # grid: {
        #   display: false,
        # },
        # display: false,
        # stacked: true
        grid: {
          display: false
        }
      },
      y: {
        grid: {
          display: false
        }
        # display: false,
      }
    }
  }
}

# const

class Dashy < Avo::BaseDashboard
  self.id = 'dashy'
  self.name = 'Dashy'
  self.description = 'The first dashbaord'
  self.grid_cols = 3

  card :Users, cols: 3, description: '' do
    area_chart User.group_by_day(:created_at).count, id: 'users'
  end

  card :Projects, cols: 2 do
    column_chart Project.unscoped.group(:progress).count, id: 'projects'
  end

  card :Posts, cols: 2 do
    pie_chart Post.group(:is_featured).count, id: 'posts'
  end

  card :Metric,
       cols: 3,
       metric: ->(context:, range:, dashboard:, card:) {
         from = Date.today.midnight - 1.week
         to = Date.today.midnight

         if range.present?
           if range.to_s == range.to_i.to_s
             from = Date.today.midnight - range.to_i.days
             to = Date.today.midnight
           else
             case range
             when 'Today'
               from = Date.today.midnight - 1.day
               to = Date.today.midnight
             end
           end
         end

         Post.where(
           'created_at >= :from AND created_at < :to',
           from: from,
           to: to
         ).count
       },
       range: 30,
       ranges: [7, 30, 60, 365, 'Today', 'YTD']
  # card :posts, cols: 2, metric: 75, suffix: '%'
  # card :posts_2, label: 'New posts', cols: 2, metric: 12, prefix: '$'

  card 'Custom card content', partial: 'avo/cards/custom_card'
end
