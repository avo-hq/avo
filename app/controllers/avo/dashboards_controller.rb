require_dependency "avo/application_controller"

module Avo
  class DashboardsController < ApplicationController
    def show
      @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]
    end

    def card
      @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]
      @card = @dashboard.items.find do |item|
        next unless item.is_card?

        item.id.to_s == params[:card_id]
      end
      if @card.present?
        @card.hydrate(dashboard: @dashboard, params: params)
      end
    end
  end
end
