class UserTypes < Avo::Dashboards::ChartkickCard
  self.id = "user_types"
  self.label = "User types"
  self.chart_type = :pie_chart
  # self.description = "Some tiny description"
  # self.cols = 2
  # self.initial_range = 30
  # self.ranges = {
  #   "7 days": 7,
  #   "30 days": 30,
  #   "60 days": 60,
  #   "365 days": 365,
  #   Today: "TODAY",
  #   "Month to date": "MTD",
  #   "Quarter to date": "QTD",
  #   "Year to date": "YTD",
  #   All: "ALL",
  # }
  self.chart_options = { donut: true }
  # self.flush = true

  def query
    active = User.where(active: true).count
    inactive = User.where(active: false).count
    result [["Active", active], ["Inactive", inactive]]
  end
end
