require_dependency "avo/application_controller"

module Avo
  class DashboardsController < ApplicationController
    before_action :set_dashboard, only: :show

    def show
    end

    private

    def set_dashboard
      @dashboard = Avo::App.get_dashboard_by_id params[:id]

      raise ActionController::RoutingError.new("Not Found") if @dashboard.nil? || @dashboard.is_hidden?
    end
  end
end
