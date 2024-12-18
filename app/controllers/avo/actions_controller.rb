require_dependency "avo/application_controller"

module Avo
  class ActionsController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_record, only: [:show, :handle], if: ->(request) do
      # Try to se the record only if the user is on the record page.
      # set_record will fail if it's tried to be used from the Index page.
      request.params[:id].present?
    end
    before_action :set_action, only: [:show, :handle]
    before_action :verify_authorization, only: [:show, :handle]
    before_action :set_query, :set_fields, only: :handle

    layout :choose_layout

    def show
      # Se the view to :new so the default value gets prefilled
      @view = Avo::ViewInquirer.new("new")

      @resource.hydrate(record: @record, view: @view, user: _current_user, params: params)
      @fields = @action.get_fields

      build_background_url
    end

    def build_background_url
      uri = URI.parse(request.url)

      # Remove the "/actions" segment from the path
      path_without_actions = uri.path.sub("/actions", "")

      params = URI.decode_www_form(uri.query || "").to_h

      params.delete("action_id")
      params[:turbo_frame] = ACTIONS_BACKGROUND_FRAME

      # Reconstruct the query string
      new_query_string = URI.encode_www_form(params)

      # Update the URI components
      uri.path = path_without_actions
      uri.query = (new_query_string == "") ? nil : new_query_string

      # Reconstruct the modified URL
      @background_url = uri.to_s
    end

    def handle
      performed_action = @action.handle_action(
        fields: @fields,
        current_user: _current_user,
        resource: @resource,
        query: @query
      )

      @response = performed_action.response
      respond
    end

    private

    def set_query
      resource_ids = action_params[:fields][:avo_resource_ids].split(",")

      @query = decrypted_query || (resource_ids.any? ? @resource.find_record(resource_ids, params: params) : [])
    end

    def set_fields
      @fields = action_params[:fields].except(:avo_resource_ids, :avo_selected_query)
    end

    def action_params
      @action_params ||= params.permit(:id, :authenticity_token, :resource_name, :action_id, :button, fields: {})
    end

    def set_action
      @action = action_class.new(
        record: @record,
        resource: @resource,
        user: _current_user,
        # force the action view to in order to render new-related fields (hidden field)
        view: Avo::ViewInquirer.new(:new),
        arguments: BaseAction.decode_arguments(params[:arguments] || params.dig(:fields, :arguments)) || {}
      )

      # Fetch action's fields
      @action.fields
    end

    def action_class
      Avo::BaseAction.descendants.find do |action|
        action.to_s == params[:action_id]
      end
    end

    def respond
      # Flash the messages collected from the action
      flash_messages

      respond_to do |format|
        format.turbo_stream do
          turbo_response = case @response[:type]
          when :keep_modal_open
            # Only render the flash messages if the action keeps the modal open
            turbo_stream.avo_flash_alerts
          when :download
            # Trigger download, removes modal and flash the messages
            [
              turbo_stream.avo_download(content: Base64.encode64(@response[:path]), filename: @response[:filename]),
              turbo_stream.avo_close_modal,
              turbo_stream.avo_flash_alerts
            ]
          when :navigate_to_action
            src, _ = @response[:action].link_arguments(resource: @action.resource, **@response[:navigate_to_action_args])

            turbo_stream.turbo_frame_set_src(Avo::MODAL_FRAME_ID, src)
          when :redirect
            [
              turbo_stream.avo_close_modal,
              turbo_stream.redirect_to(
                Avo::ExecutionContext.new(target: @response[:path]).handle,
                turbo_frame: @response[:redirect_args][:turbo_frame],
                **@response[:redirect_args].except(:turbo_frame)
              )
            ]
          when :close_modal
            # Close the modal and flash the messages
            [
              turbo_stream.avo_close_modal,
              turbo_stream.avo_flash_alerts
            ]
          else
            # Reload the page
            back_path = request.referer || params[:referrer].presence || resources_path(resource: @resource)

            [
              turbo_stream.avo_close_modal,
              turbo_stream.redirect_to(back_path)
            ]
          end

          responses = if @action.appended_turbo_streams.present?
            Array(turbo_response) + Array(instance_exec(&@action.appended_turbo_streams))
          else
            Array(turbo_response)
          end

          render turbo_stream: responses
        end
      end
    end

    def get_messages
      default_message = {
        type: :info,
        body: I18n.t("avo.action_ran_successfully")
      }

      return [default_message] if @response[:messages].blank?

      @response[:messages].select do |message|
        # Remove the silent placeholder messages
        message[:type] != :silent
      end
    end

    def decrypted_query
      return if (encrypted_query = action_params[:fields][:avo_selected_query]).blank?

      Avo::Services::EncryptionService.decrypt(message: encrypted_query, purpose: :select_all, serializer: Marshal)
    end

    def flash_messages
      get_messages.each do |message|
        flash[message[:type]] = message[:body]
      end
    end

    def verify_authorization
      raise Avo::NotAuthorizedError.new unless @action.authorized?
    end
  end
end
