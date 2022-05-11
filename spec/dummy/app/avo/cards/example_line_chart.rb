class ExampleLineChart < Avo::Dashboards::ChartkickCard
  self.id = "line_chart"
  self.label = "Line chart"
  self.chart_type = :line_chart
  self.cols = 1
  self.flush = true
  self.scale = false
  self.legend = false

  def query
    data = 3.times.map do |index|
      {
        name: "Batch #{index}",
        data: 17.times.map { |i| [i, Random.rand(32)] }
      }
    end

    result(data)
  end
end
