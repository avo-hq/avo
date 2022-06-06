require_dependency "avo/application_controller"

module Avo
  class CardsController < ApplicationController
    before_action :set_dashboard
    before_action :set_resource_name
    before_action :set_resource, if: -> { @dashboard.blank? }
    before_action :set_model, only: :show, if: -> { @resource.present? }
    before_action :hydrate_resource, if: -> { @resource.present? }
    before_action :set_parent, only: :show
    before_action :set_card, only: :show

    def show
    end

    private

    def set_parent
      @parent = @dashboard || @resource
    end

    def set_dashboard
      return if params[:dashboard_id].blank?

      @dashboard_class = Avo::App.get_dashboard_by_id params[:dashboard_id]

      raise ActionController::RoutingError.new("Not Found") if @dashboard_class.nil? || @dashboard_class.is_hidden?

      @dashboard = @dashboard_class.new
    end

    def set_card
      @card = @parent.item_at_index(params[:index].to_i).tap do |card|
        card.hydrate(parent: @parent, params: params)
      end
    end
  end
end
