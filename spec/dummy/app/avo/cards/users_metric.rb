class UsersMetric < Avo::Dashboards::MetricCard
  self.id = "users_metric"
  self.label = "Users metric"
  # self.description = "Some description"
  # self.cols = 1
  # self.initial_range = 30
  # self.ranges = [7, 30, 60, 365, "TODAY", "MTD", "QTD", "YTD", "ALL"]
  # self.prefix = ""
  # self.suffix = ""

  query do
    puts ["options->", options].inspect
    result User.count
  end
end
