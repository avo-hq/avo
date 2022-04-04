class ExampleMetric < Avo::Dashboards::MetricCard
  self.id = "users_metric"
  self.label = "Users count"
  self.description = "Users description"
  self.cols = 1
  self.initial_range = 30
  self.ranges = [7, 30, 60, 365, "TODAY", "MTD", "QTD", "YTD", "ALL"]
  # self.prefix = "$"
  # self.suffix = "%"
  self.refresh_every = 10.minutes

  # You have access to context, params, range, current dashboard, and current card
  query do
    from = Date.today.midnight - 1.week
    to = DateTime.current

    if range.present?
      if range.to_s == range.to_i.to_s
        from = DateTime.current - range.to_i.days
      else
        case range
        when "TODAY"
          from = DateTime.current.beginning_of_day
        when "MTD"
          from = DateTime.current.beginning_of_month
        when "QTD"
          from = DateTime.current.beginning_of_quarter
        when "YTD"
          from = DateTime.current.beginning_of_year
        when "ALL"
          from = Time.at(0)
        end
      end
    end

    scope = User

    if card.options[:active_users].present?
      scope = scope.active
    end

    result scope.where(created_at: from..to).count
  end
end
