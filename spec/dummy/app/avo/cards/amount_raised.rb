class AmountRaised < Avo::Dashboards::MetricCard
  self.id = "amount_raised"
  self.label = "Amount raised"
  # self.description = "Some description"
  # self.cols = 1
  # self.initial_range = 30
  # self.ranges = [7, 30, 60, 365, "TODAY", "MTD", "QTD", "YTD", "ALL"]
  self.prefix = "$"
  # self.suffix = ""

  def query
    result 9001
  end
end
