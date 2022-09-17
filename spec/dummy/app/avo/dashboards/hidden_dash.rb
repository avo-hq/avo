class HiddenDash < Avo::Dashboards::BaseDashboard
  self.id = "hidden_dash"
  self.name = "Hidden dash"
  self.description = "Hidden dash description"
  self.visible = -> {
    false
  }
  # self.grid_cols = 3

  # cards go here
  # card metric: UsersCount
end
