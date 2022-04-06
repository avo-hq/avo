class ExampleCustomPartial < Avo::Dashboards::PartialCard
  self.id = "users_custom_card"
  self.cols = 1
  self.rows = 4
  self.partial = "avo/cards/custom_card"
  self.description = "This card has been loaded from a custom partial and has access to the options hash and the dashboard params."
end
