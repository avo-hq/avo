class Avo::Menu::Dashboard < Avo::Menu::BaseItem
  extend Dry::Initializer

  option :dashboard
  option :label, optional: true

  def parsed_dashboard
    dashboard_by_id || dashboard_by_name
  end

  def dashboard_by_name
    Avo::App.get_dashboard_by_name dashboard.to_s
  end

  def dashboard_by_id
    Avo::App.get_dashboard_by_id dashboard.to_s
  end

  def entity_label
    parsed_dashboard.navigation_label
  end
end
