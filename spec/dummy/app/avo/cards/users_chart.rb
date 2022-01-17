class UsersChart < Avo::BaseChartkick
  self.label = 'Birthdays'
  self.description = 'User birthdays'
  self.cols = 3
  self.range = 30
  self.ranges = [7, 30, 60, 365, 'Today', 'YTD']
  self.chart_type = :area_chart
  self.chart_options = {
    library: {
      plugins: {
        legend: {
          display: false
        }
      }
    }
  }

  def query(context:, range:, dashboard:, card:)
    [
      {
        name: 'Users birthday',
        data: User.group_by_year(:birthday).count
      },
      {
        name: 'Other users',
        data: User.group_by_year(:birthday).count.map { |key, value| [key, rand(0..4)] }.to_h
      },
      {
        name: 'Some more users',
        data: User.group_by_year(:birthday).count.map { |key, value| [key, rand(0..3)] }.to_h
      }
    ]
    # from = Date.today.midnight - 1.week
    # to = Date.today.midnight

    # if range.present?
    #   if range.to_s == range.to_i.to_s
    #     from = Date.today.midnight - range.to_i.days
    #     to = Date.today.midnight
    #   else
    #     case range
    #     when 'Today'
    #       from = Date.today.midnight - 1.day
    #       to = Date.today.midnight
    #     end
    #   end
    # end

    # Post.where('created_at >= :from AND created_at < :to', from: from, to: to)
    #   .count
  end
end
