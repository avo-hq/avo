class UserMetric < Avo::Dashboards::MetricCard
  self.id = "user_metric"
  self.label = "User metric"
  # self.description = "Some description"
  # self.cols = 1
  # self.initial_range = 30
  # self.ranges = [7, 30, 60, 365, "TODAY", "MTD", "QTD", "YTD", "ALL"]
  # self.prefix = ""
  # self.suffix = ""

  query do
    if options[:get] == :comments
      result parent.model.comments.count
    end
    if options[:get] == :posts
      result parent.model.posts.count
    end
    if options[:get] == :projects
      result parent.model.projects.count
    end
  end
end
