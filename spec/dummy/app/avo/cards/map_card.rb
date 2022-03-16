class MapCard < Avo::Dashboards::PartialCard
  self.id = "map_card"
  self.label = "Map card"
  self.partial = "avo/cards/map_card"
  self.display_header = false
  self.cols = 2
  self.rows = 4
end
