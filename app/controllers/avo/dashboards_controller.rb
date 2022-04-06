require_dependency "avo/application_controller"

module Avo
  class DashboardsController < ApplicationController
    before_action :set_dashboard

    def show
    end

    def card
      @card = @dashboard.item_at_index(params[:index].to_i).tap do |card|
        card.hydrate(dashboard: @dashboard, params: params)
      end
    end

    private

    def set_dashboard
      @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]

      raise ActionController::RoutingError.new("Not Found") if @dashboard.nil? || @dashboard.is_hidden?
    end
  end
end
