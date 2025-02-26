module Avo
  class BulkUpdateController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_query, :set_fields, :verify_authorization, only: [:edit, :update]

    def edit
      @prefilled_fields = prefill_fields(@query, @fields)
      render layout: false
    end

    def update
      @resources.each_with_index do |resource, index|
        record = @query[index]
        @fields.each do |field_name, new_value|
          resource.fill_field(record, field_name, new_value) if new_value.present?
        end
        record.save!
      end

      flash[:notice] = I18n.t("avo.bulk_update.success", count: @query.size)
      redirect_to resources_path(resource: @resources.first)
    end

    private

    def prefill_fields(records, fields)
      prefilled = {}
      fields.each_key do |field_name|
        values = records.map { |record| record.public_send(field_name) }
        prefilled[field_name] = (values.uniq.size == 1 ? values.first : nil)
      end
      prefilled
    end

    def set_resources
      raise ActionController::RoutingError.new "No route matches" if @query.nil? || @query.empty?

      @resources = @query.map do |record|
        resource.new(view: params[:view].presence || action_name.to_s, user: _current_user, params: params, record: record)
      end

      set_authorization
    end

    def set_query
      resource_ids = action_params[:fields]&.dig(:avo_resource_ids)&.split(",") || []

      @query = decrypted_query || (resource_ids.any? ? @resource.find_record(resource_ids, params: params) : [])
    end

    def set_fields
      @fields = action_params[:fields].except(:avo_resource_ids, :avo_selected_query)
    end

    def action_params
      @action_params ||= params.permit(:authenticity_token, :resource_name, :button, :arguments, fields: {})
    end

    def decrypted_query
      return if (encrypted_query = action_params[:fields]&.dig(:avo_selected_query)).blank?

      Avo::Services::EncryptionService.decrypt(message: encrypted_query, purpose: :select_all, serializer: Marshal)
    end

    def verify_authorization
      raise Avo::NotAuthorizedError.new unless @action.authorized?
    end
  end
end
