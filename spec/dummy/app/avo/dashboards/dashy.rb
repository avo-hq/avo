class Dashy < Avo::Dashboards::BaseDashboard
  self.id = "dashy"
  self.name = "Dashy"
  self.description = "The first dashbaord"
  self.grid_cols = 3
  # self.visible = -> do
  #   true
  # end

  card ExampleMetric
  card ExampleAreaChart
  card ExampleScatterChart
  card ExampleMetric,
    label: "Active users metric",
    description: "Count of the active users.",
    options: {
      active_users: true
    }
  card PercentDone
  card ExampleLineChart, cols: 1
  card AmountRaised
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
