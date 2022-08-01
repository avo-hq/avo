require_dependency "avo/application_controller"

module Avo
  class CardsController < ApplicationController
    before_action :set_dashboard
    before_action :set_resource_t
    # before_action :set_model, only: :show_for_record
    before_action :set_model, only: [:show, :show_for_record]
    # before_action :set_model, only: [:show, :show_for_record], if: -> { @resource.present? }
    before_action :hydrate_resource, only: [:show_for_record, :show_for_resource]
    # before_action :set_resource_name
    before_action :set_resource, if: -> { @dashboard.blank? }
    before_action :hydrate_resource, if: -> { @resource.present? }
    before_action :set_parent, only: :show
    before_action :set_card, only: :show

    def show
    end

    def show_for_resource
      abort ['show_for_resource', params].inspect
      show
    end

    def show_for_record
      abort ['show_for_record', params].inspect
      show
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

    # def set_model
    #   @model = eager_load_files(@resource, @resource.class.find_scope).find params[:id]
    # end

    def set_resource_t
      puts ["resource_set->"].inspect
      @resource = Avo::App.get_resource_by_name params[:resource_name]
      # abort @resource.inspect
    end

    # def set_record
    #   @record = Avo::App.get_resource_by_name params[:resource_name]
    # end

    def hydrate_resource
      # abort [@resource, @model].inspect
      @resource.hydrate(params: params, model: @record)
    end
  end
end
