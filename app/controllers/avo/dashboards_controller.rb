require_dependency "avo/application_controller"

module Avo
  class DashboardsController < ApplicationController
    before_action :set_dashboard, only: :show

    def show
    end

    private

    def set_dashboard
      @dashboard_class = Avo::App.get_dashboard_by_id params[:id]

      raise ActionController::RoutingError.new("Not Found") if @dashboard_class.nil? || @dashboard_class.is_hidden?

      @dashboard = @dashboard_class.new.hydrate(params: params) if @dashboard_class.present?
    end
  end
end
