class ExampleColumnChart < Avo::Dashboards::ChartkickCard
  self.id = "example_column_chart"
  self.label = "Example column chart"
  self.chart_type = :column_chart
  # self.flush = false
  # self.legend = true
  # self.scale = true
  # self.legend_on_left = true

  def query
    result [["Sun", 32], ["Mon", 46], ["Tue", 28], ["Wed", 21], ["Thu", 20], ["Fri", 13], ["Sat", 27]]
  end
end
