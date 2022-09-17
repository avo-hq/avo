class ExampleScatterChart < Avo::Dashboards::ChartkickCard
  self.id = "scatter"
  self.label = "Scatter"
  self.chart_type = :scatter_chart
  self.cols = 2
  self.description = "Hey"
  self.flush = false
  self.legend = true
  self.scale = true
  self.legend_on_left = true

  def query
    result [
      {
        name: "batch 1",
        data: 16.times.map { |i| [i + 1, Random.rand(32)] }
      },
      {
        name: "batch 1",
        data: 16.times.map { |i| [i + 1, Random.rand(32)] }
      },
      {
        name: "batch 1",
        data: 16.times.map { |i| [i + 1, Random.rand(32)] }
      }
    ]
  end
end
