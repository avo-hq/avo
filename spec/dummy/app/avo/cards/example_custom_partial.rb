class ExampleCustomPartial < Avo::Dashboards::PartialCard
  self.id = "users_custom_card"
  self.cols = 1
  self.rows = 4
  self.partial = "avo/cards/custom_card"
end
