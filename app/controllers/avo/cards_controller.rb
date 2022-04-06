require_dependency "avo/application_controller"

module Avo
  class CardsController < ApplicationController
    before_action :set_dashboard
    before_action :set_resource_name
    before_action :set_resource, if: -> { @dashboard.blank? }
    before_action :hydrate_resource, if: -> { @dashboard.blank? }
    before_action :set_model, only: :show, if: -> { @dashboard.blank? }
    before_action :set_parent, only: :show

    def show
      @card = @parent.item_at_index(params[:index].to_i).tap do |card|
        card.hydrate(parent: @parent, params: params)
      end
    end

    private

    def set_dashboard
      return if params[:dashboard_id].blank?

      @dashboard = Avo::App.get_dashboard_by_id params[:dashboard_id]
    end

    def set_parent
      @parent = @dashboard || @resource
    end
  end
end
