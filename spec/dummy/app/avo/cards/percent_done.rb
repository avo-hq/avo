class PercentDone < Avo::Dashboards::MetricCard
  self.id = "percent_done"
  self.label = "Percent done"
  self.description = "This is the progress we made so far..."
  self.suffix = "%"

  def query
    result 42
  end
end
