class ExamplePieChart < Avo::Dashboards::ChartkickCard
  self.id = "example_pie_chart"
  self.label = "Example pie chart"
  self.chart_type = :pie_chart
  self.cols = 1
  self.flush = false
  self.legend = true
  self.scale = true
  self.legend_on_left = true

  def query
    result [["Blueberry", 44], ["Strawberry", 23], ["Banana", 22], ["Apple", 21], ["Grape", 13], ["Pear", 53], ["Avocado", 15]]
  end
end
