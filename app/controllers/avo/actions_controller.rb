require_dependency "avo/application_controller"

module Avo
  class ActionsController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_record, only: :show, if: ->(request) do
      # Try to se the record only if the user is on the record page.
      # set_record will fail if it's tried to be used from the Index page.
      request.params[:id].present?
    end
    before_action :set_action, only: [:show, :handle]
    before_action :verify_authorization, only: [:show, :handle]

    def show
      # Se the view to :new so the default value gets prefilled
      @view = Avo::ViewInquirer.new("new")

      @resource.hydrate(record: @record, view: @view, user: _current_user, params: params)
    end

    def handle
      resource_ids = action_params[:fields][:avo_resource_ids].split(",")

      performed_action = @action.handle_action(
        fields: action_params[:fields].except(:avo_resource_ids, :avo_selected_query),
        current_user: _current_user,
        resource: resource,
        query: decrypted_query || @resource.find_record(resource_ids, params: params)
      )

      respond performed_action.response
    end

    private

    def action_params
      params.permit(:authenticity_token, :resource_name, :action_id, :button, fields: {})
    end

    def set_action
      @action = action_class.new(
        record: @record,
        resource: @resource,
        user: _current_user,
        view: :new, # force the action view to in order to render new-related fields (hidden field)
        arguments: decrypted_arguments || {}
      )
    end

    def action_class
      Avo::BaseAction.descendants.find do |action|
        action.to_s == params[:action_id]
      end
    end

    def respond(response)
      messages = get_messages response
      return keep_modal_open(messages) if response[:keep_modal_open]

      response[:type] ||= :reload

      if response[:type] == :download
        return send_data response[:path], filename: response[:filename]
      end

      respond_to do |format|
        format.turbo_stream do
          # Flash the messages collected from the action
          flash_messages messages

          if response[:type] == :redirect
            render turbo_stream: turbo_stream.redirect_to(
              Avo::ExecutionContext.new(target: response[:path]).handle,
              nil,
              response[:redirect_args][:turbo_frame],
              **response[:redirect_args].except(:turbo_frame)
            )
          else
            redirect_back fallback_location: resources_path(resource: @resource)
          end
        end
      end
    end

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

    def decrypted_query
      return if (encrypted_query = action_params[:fields][:avo_selected_query]).blank?

      Avo::Services::EncryptionService.decrypt(message: encrypted_query, purpose: :select_all, serializer: Marshal)
    end

    def decrypted_arguments
      arguments = params[:arguments] || params.dig(:fields, :arguments)
      return if arguments.blank?

      Avo::Services::EncryptionService.decrypt(
        message: Base64.decode64(arguments),
        purpose: :action_arguments
      )
    end

    def flash_messages(messages)
      messages.each do |message|
        flash[message[:type]] = message[:body]
      end
    end

    def keep_modal_open(messages)
      flash_messages messages

      respond_to do |format|
        format.turbo_stream do
          render partial: "avo/partials/flash_alerts"
        end
      end
    end

    def verify_authorization
      raise Avo::NotAuthorizedError.new unless @action.authorized?
    end
  end
end
