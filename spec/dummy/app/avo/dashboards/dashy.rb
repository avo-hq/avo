class Dashy < Avo::Dashboards::BaseDashboard
  self.id = "dashy"
  self.name = "Dashy"
  self.description = "The first dashbaord"
  self.grid_cols = 3
  # self.visible = -> do
  #   true
  # end

  card ExampleMetric
  card ExampleMetric, options: {
    active_users: true
    # @todo: add the ability to change the card title and description from here.
  }
  card ExampleAreaChart
  card ExampleScatterChart
  card PercentDone
  card AmountRaised
  card ExampleLineChart
  card ExampleColumnChart
  card ExamplePieChart
  card ExampleBarChart

  divider label: "Custom partials"

  card ExampleCustomPartial, options: {
    foo: "bar",
    block: ->(params = nil) {
      "Hello from the block"
    }
  }
  card MapCard
end
