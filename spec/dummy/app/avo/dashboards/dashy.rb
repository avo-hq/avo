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

  card ExampleLineChart, cols: 1
  card MapCard
  card ExamplePieChart
  card ExampleBarChart
  card ExampleColumnChart
  card AmountRaised
  card ExampleMetric,
  label: "Active users metric",
    description: "Count of the active users.",
    options: {
      active_users: true
    }
    card PercentDone
    card ExampleScatterChart, cols: 3

  divider label: "Custom partials"

  card ExampleCustomPartial, options: {
    foo: "bar",
    block: ->(params = nil) {
      "Hello from the block"
    }
  }
end
