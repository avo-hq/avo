require_dependency 'avo/application_controller'

module Avo
  class ActionsController < ApplicationController
    def index
      # abort [avo_resource, params].inspect
      set_actions
      # @model = resource_model
    end

    def post
      abort params.inspect
    end

    def show
      set_actions
      # abort [1, params].inspect

      @resource_model = resource_model
      action_class = params[:action_id].gsub('avo_actions_', '').classify
      action_name = "Avo::Actions::#{action_class}"
      action = action_name.safe_constantize
      # abort action.inspect

      model = nil
      # abort action.new.inspect

      fields = action.get_fields.map { |field| field.fetch_for_action(model, avo_resource) }
      # abort [fields].inspect

        # {
        #   id: id,
        #   name: name,
        #   fields: fields,
        #   message: message,
        #   theme: theme,
        #   confirm_text: confirm_text,
        #   cancel_text: cancel_text,
        #   default: default,
        #   action_class: self.class.to_s,
        #   no_confirmation: no_confirmation,
        # }
      # abort [avo_resource, @resource_model, params].inspect
      @action = @actions.find do |action|
        action.id == params[:action_id]
      end
      @fields = fields
      # abort @action.inspect
      # abort 123.inspect
    end

    def set_actions
      avo_actions = avo_resource.get_actions
      actions = []

      if params[:resource_id].present?
        model = resource_model.find params[:resource_id]
      end

      avo_actions.each do |action|
        action = action.new

        action.set_model model
        action.set_resource avo_resource

        actions.push(action)
      end

      @actions = actions
    end

    def index_old
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
      abort resource_model.inspect
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
