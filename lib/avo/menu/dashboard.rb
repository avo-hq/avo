class Avo::Menu::Dashboard < Avo::Menu::BaseItem
  extend Dry::Initializer

  option :dashboard

  def parsed_dashboard
    dashboard_by_id || dashboard_by_name
  end

  def dashboard_by_name
    Avo::App.get_dashboard_by_name dashboard.to_s
  end

  def dashboard_by_id
    Avo::App.get_dashboard_by_id dashboard.to_s
  end
end
