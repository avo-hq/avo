require_dependency "avo/application_controller"

module Avo
  class ActionsController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_action, only: [:show, :handle]

    def show
      @model = ActionModel.new @action.get_attributes_for_action
    end

    def handle
      resource_ids = action_params[:fields][:avo_resource_ids].split(",")
      selected_query = action_params[:fields][:avo_selected_query]

      models = if selected_query.present?
        ActiveRecord::Base.connection.exec_query base64_decode_query
      else
        @resource.class.find_scope.find resource_ids
      end

      fields = action_params[:fields].except(:avo_resource_ids, :avo_selected_query)

      args = {
        fields: fields,
        current_user: _current_user,
        resource: resource
      }

      args[:models] = models unless @action.standalone

      performed_action = @action.handle_action(**args)

      respond performed_action.response
    end

    private

    def action_params
      params.permit(:authenticity_token, :resource_name, :action_id, fields: {})
    end

    def set_action
      action_class = params[:action_id].gsub("avo_actions_", "").camelize.safe_constantize

      if params[:id].present?
        model = @resource.class.find_scope.find params[:id]
      end

      @action = action_class.new(model: model, resource: resource, user: _current_user, view: :edit)
    end

    def respond(response)
      response[:type] ||= :reload
      messages = get_messages response

      if response[:type] == :download
        return send_data response[:path], filename: response[:filename]
      end

      respond_to do |format|
        format.html do
          # Flash the messages collected from the action
          messages.each do |message|
            flash[message[:type]] = message[:body]
          end

          if response[:type] == :redirect
            path = response[:path]

            if path.respond_to? :call
              path = instance_eval(&path)
            end

            redirect_to path
          elsif response[:type] == :reload
            redirect_back fallback_location: resources_path(resource: @resource)
          end
        end
      end
    end

    private

    def get_messages(response)
      default_message = {
        type: :info,
        body: I18n.t("avo.action_ran_successfully")
      }

      return [default_message] if response[:messages].blank?

      response[:messages].select do |message|
        # Remove the silent placeholder messages
        message[:type] != :silent
      end
    end

    def base64_decode_query
      Base64.decode64 action_params[:fields][:avo_selected_query]
    end
  end
end
