class Scatter < Avo::Dashboards::ChartkickCard
  self.id = "scatter"
  self.label = "Scatter"
  self.chart_type = :scatter_chart
  self.cols = 2

  def query(context:, range:, dashboard:, card:)
    [
      {
        name: "batch 1",
        data: [[1, 2], [2, 7], [3, 3], [4, 5], [5, 1], [6, 8]]
      },
      {
        name: "batch 1",
        data: [[1, 3], [2, 2], [3, 1], [4, 7], [5, 1], [6, 2]]
      },
      {
        name: "batch 1",
        data: [[1, 5], [2, 3], [3, 6], [4, 1], [5, 2], [6, 1]]
      }
    ]
  end
end
