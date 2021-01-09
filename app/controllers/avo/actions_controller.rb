require_dependency 'avo/application_controller'

module Avo
  class ActionsController < ApplicationController
    before_action :set_action, only: [:show, :handle]

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
      # abort action.inspect

      model = nil
      # abort action.new.inspect

      fields = @action.get_fields.map { |field| field.fetch_for_action(model, avo_resource) }
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
      # abort action_params.inspect
      resource_ids = action_params[:fields][:resource_ids].split(',').map(&:to_i)
      fields = action_params[:fields].select { |key| key != 'resource_ids' }
      # abort fields.inspect
      # abort resource_ids.inspect
      models = resource_model.find resource_ids
      avo_action = @action.new
      # abort avo_action.inspect
      performed_action = avo_action.handle_action(request, models, fields)

      # abort performed_action.inspect

      response = performed_action.response

      respond response
    end

    private
      def action_params
        params.permit(:resource_name, :action_id, fields: {})
      end

      def set_action
        action_class = params[:action_id].gsub('avo_actions_', '').classify
        action_name = "Avo::Actions::#{action_class}"
        @action = action_name.safe_constantize
      end

      def respond(response)
        response[:type] ||= :reload
        response[:message_type] ||= :notice
        response[:message] ||= I18n.t('avo.action_ran_successfully')

        if response[:type] == :download
          return send_data response[:path], filename: response[:filename]
        end

        abort response.inspect

        respond_to do |format|
          format.html do
            if response[:type] == :redirect
              path = response[:path]

              if path.respond_to? :call
                path = instance_eval &path
              end

              redirect_to path, "#{response[:message_type]}": response[:message]
            elsif response[:type] == :reload
              redirect_back fallback_location: resources_path(resource_model), "#{response[:message_type]}": response[:message]
            end
          end
        end
      end
  end
end
