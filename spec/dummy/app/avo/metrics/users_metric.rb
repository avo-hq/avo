class UsersMetric < Avo::BaseMetric
  # self.label = 'Users count'
  # self.cols = 3
  # self.range = 30
  # self.ranges = [7, 30, 60, 365, 'Today', 'YTD']

  def value(context:, range:, dashboard:, card:)
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

    Post.where('created_at >= :from AND created_at < :to', from: from, to: to)
      .count
  end
end
