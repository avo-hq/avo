require_dependency "avo/application_controller"

module Avo
  class DashboardsController < ApplicationController
    def show
      @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]
    end
  end
end
