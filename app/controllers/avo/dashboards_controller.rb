require_dependency "avo/application_controller"

module Avo
  class DashboardsController < ApplicationController
    before_action :set_dashboard, only: :show

    def show
      @page_title = @dashboard.name
    end

    private

    def set_dashboard
      @dashboard = Avo::App.get_dashboard_by_id params[:id]

      authorized = Avo::Hosts::BaseHost.new(block: @dashboard.authorize).handle
      raise Avo::NotAuthorizedError.new if !authorized

      raise ActionController::RoutingError.new("Not Found") if @dashboard.nil? || @dashboard.is_hidden?
    end
  end
end
