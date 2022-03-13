class ScatterChart < Avo::Dashboards::ChartkickCard
  self.id = "scatter"
  self.label = "Scatter"
  self.chart_type = :scatter_chart
  self.cols = 2

  def query(context:, range:, dashboard:, card:)
    [
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
