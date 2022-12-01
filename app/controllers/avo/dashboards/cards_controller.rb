require_dependency "avo/application_controller"

module Avo
  module Dashboards
    class CardsController < ApplicationController
      before_action :set_dashboard
      before_action :set_card
      before_action :detect_chartkick

      def show
        render(:chartkick_missing) unless @chartkick_installed
      end

      private

      def set_dashboard
        @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]

        raise ActionController::RoutingError.new("Not Found") if @dashboard.nil? || @dashboard.is_hidden?
      end

      def set_card
        @card = @dashboard.item_at_index(params[:index].to_i).tap do |card|
          card.hydrate(dashboard: @dashboard)
        end
      end

      def detect_chartkick
        @chartkick_installed = if @card.class.ancestors.map(&:to_s).include?("Avo::Dashboards::ChartkickCard")
          defined?(Chartkick)
        else
          true
        end
      end
    end
  end
end
