require_dependency "avo/application_controller"

module Avo
  class ActionsController < ApplicationController
    def index
      avo_actions = avo_resource.get_actions
      actions = []
      if params[:resource_id].present?
        model = resource_model.safe_constantize.find params[:resource_id]
      end

      avo_actions.each do |action|
        actions.push(action.new(model).render_response model, avo_resource)
      end

      render json: {
        actions: actions,
      }
    end

    def handle
      model = resource_model.safe_constantize.find params[:resource_id]
      avo_action = params[:action_class].safe_constantize.new
      response = avo_action.handle request, model, params[:fields]

      render json: {
        success: true,
        response: response,
        fields: params[:fields],
      }
    end

    private
      def resource_model
        params[:resource_name].to_s.camelize.singularize
      end

      def avo_resource
        App.get_resource resource_model
      end
  end
end
