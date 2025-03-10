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

      resource_key = @resource_name.downcase.to_sym
      current_params = params[resource_key] || {}

      progress_fields = @resource
        .get_field_definitions
        .select { |field| field.is_a?(Avo::Fields::ProgressBarField) }
        .map(&:id)
        .map(&:to_sym)

      current_params.reject do |key, value|
        key_sym = key.to_sym
        prefilled_value = prefilled_params[key_sym]

        next true if progress_fields.include?(key_sym) && prefilled_value == "" && value.to_s == "50"

        prefilled_value.to_s == value.to_s
      end
    end

    def update_records
      updated_count = 0
      failed_records = []

      @query.each do |record|
        params_to_apply.each do |key, value|
          record.public_send(:"#{key}=", value)
        rescue => e
          puts "Błąd przypisywania pola #{key}: #{e.message}"
        end

        @resource.fill_record(record, params)

        if record.save
          updated_count += 1
        else
          failed_records << {record: record, errors: record.errors.full_messages}
        end
      rescue => e
        failed_records << {record: record, errors: [e.message]}
      end

      [updated_count, failed_records]
    end

    def after_bulk_update_path
      resources_path(resource: @resource)
    end

    def prefill_fields(records, fields)
      prefilled = {}
      fields.each_key do |field_name|
        values = records.map { |record| record.public_send(field_name) }
        prefilled[field_name] = (values.uniq.size == 1 ? values.first : nil)
      end
      prefilled
    end

    def set_query
      if params[:query].present?
        @query = @resource.find_record(params[:query], params: params)
      else
        resource_ids = action_params[:fields]&.dig(:avo_resource_ids)&.split(",") || []
        @query = decrypted_query || (resource_ids.any? ? @resource.find_record(resource_ids, params: params) : [])
      end
    end

    def set_fields
      if @query.blank?
        flash[:error] = "Bulk update cannot be performed without records."
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
