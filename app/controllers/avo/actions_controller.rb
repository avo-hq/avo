require_dependency 'avo/application_controller'

module Avo
  class ActionsController < ApplicationController
    def index
      avo_actions = avo_resource.get_actions
      actions = []

      if params[:resource_id].present?
        model = resource_model.find params[:resource_id]
      end

      avo_actions.each do |action|
        actions.push(action.new.render_response model, avo_resource)
      end

      render json: {
        actions: actions,
      }
    end

    def handle
      models = resource_model.find action_params[:resource_ids]
      avo_action = action_params[:action_class].safe_constantize.new
      avo_action.handle_action(request, models, action_params[:fields])

      render json: {
        success: true,
        response: avo_action.response,
      }
    end

    private
      def action_params
        params.permit(:resource_name, :action_id, :action_class, resource_ids: [], fields: {})
      end
  end
end
