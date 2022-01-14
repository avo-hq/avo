require_dependency "avo/application_controller"

module Avo
  class DashboardsController < ApplicationController
    def show
      @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]
    end

    def card
      @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]
      @card = @dashboard.cards.find do |card|
        card.id.to_s == params[:card_id]
      end
      @range = params[:range] || @card.ranges.first
    end
  end
end
