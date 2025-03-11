module Avo
  class BulkUpdateController < ResourcesController
    before_action :set_query, only: [:edit, :handle]
    before_action :set_fields, only: [:edit, :handle]

    def edit
      @prefilled_fields = prefill_fields(@query, @fields)
      @record = @resource.model_class.new(@prefilled_fields.transform_values { |v| v.nil? ? nil : v })

      @resource.record = @record
      render Avo::Views::ResourceEditComponent.new(
        resource: @resource,
        query: @query,
        prefilled_fields: @prefilled_fields
      )
    end

    def handle
      if params_to_apply.blank?
        flash[:warning] = t("avo.no_changes_made")
        redirect_to after_bulk_update_path
        return
      end

      updated_count, failed_records = update_records

      if failed_records.empty?
        flash[:notice] = t("avo.bulk_update_success", count: updated_count)
      else
        error_messages = failed_records.flat_map { |fr| fr[:errors] }.uniq
        flash[:error] = t("avo.bulk_update_failure", count: failed_records.count, errors: error_messages.join(", "))
      end

      redirect_to after_bulk_update_path
    end

    private

    def params_to_apply
      prefilled_params = params[:prefilled] || {}
      current_params = current_resource_params
      progress_fields = progress_bar_fields

      current_params.reject do |key, value|
        key_sym = key.to_sym
        prefilled_value = prefilled_params[key_sym]

        progress_field_with_default?(progress_fields, key_sym, prefilled_value, value) ||
          prefilled_value.to_s == value.to_s
      end
    end

    def current_resource_params
      resource_key = @resource_name.downcase.to_sym
      params[resource_key] || {}
    end

    def progress_bar_fields
      @resource.get_field_definitions
        .select { |field| field.is_a?(Avo::Fields::ProgressBarField) }
        .map(&:id)
        .map(&:to_sym)
    end

    def progress_field_with_default?(progress_fields, key_sym, prefilled_value, value)
      progress_fields.include?(key_sym) && prefilled_value == "" && value.to_s == "50"
    end

    def update_records
      updated_count = 0
      failed_records = []

      @query.each do |record|
        update_record(record, params_to_apply)
        record.save ? updated_count += 1 : add_failed_record(failed_records, record)
      end

      [updated_count, failed_records]
    end

    def update_record(record, params_to_apply)
      params_to_apply.each do |key, value|
        record.public_send(:"#{key}=", value)
      end

      @resource.fill_record(record, params)
    end

    def add_failed_record(failed_records, record, error_message = nil)
      errors = error_message ? [error_message] : record.errors.full_messages
      failed_records << {record: record, errors: errors}
    end

    def after_bulk_update_path
      resources_path(resource: @resource)
    end

    def prefill_fields(records, fields)
      fields.each_key.with_object({}) do |field_name, prefilled|
        values = records.map { |record| record.public_send(field_name) }
        values.uniq!
        prefilled[field_name] = if values.size == 1
          values.first
        else
          nil
        end
      end
    end

    def set_query
      @query = if params[:query].present?
        @resource.find_record(params[:query], params: params)
      else
        find_records_by_resource_ids
      end
    end

    def find_records_by_resource_ids
      resource_ids = action_params[:fields]&.dig(:avo_resource_ids)&.split(",") || []
      decrypted_query || (resource_ids.any? ? @resource.find_record(resource_ids, params: params) : [])
    end

    def set_fields
      if @query.blank?
        flash[:error] = I18n.t("avo.bulk_update_no_records")
        redirect_to after_bulk_update_path
      else
        @fields = @query.first.attributes.keys.index_with { nil }
      end
    end

    def action_params
      @action_params ||= params.permit(:authenticity_token, fields: {})
    end

    def decrypted_query
      encrypted_query = action_params[:fields]&.dig(:avo_selected_query) || params[:query]

      return if encrypted_query.blank?

      Avo::Services::EncryptionService.decrypt(message: encrypted_query, purpose: :select_all, serializer: Marshal)
    end
  end
end
