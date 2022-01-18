class CustomPartial < Avo::Dashboards::PartialCard
  self.id = 'users_custom_card'
  self.cols = 3
  self.partial = 'avo/cards/custom_card'
end
