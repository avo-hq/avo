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
        query: @query
      )
    end

    def handle
      saved = save_records

      if saved
        flash[:notice] = t("avo.bulk_update_success")
      else
        flash[:error] = t("avo.bulk_update_failure")
      end

      redirect_to after_bulk_update_path
    end

    private

    def update_records
      params_to_apply = params[@resource_name.downcase.to_sym].compact_blank || {}

      @query.each do |record|
        @resource.fill_record(record, params_to_apply)
      end
    end

    def save_records
      update_records

      all_saved = true

      ActiveRecord::Base.transaction do
        @query.each do |record|
          @record = record
          save_record
        end
      rescue ActiveRecord::RecordInvalid => e
        all_saved = false
        puts "Failed to save #{record.id}: #{e.message}"
        raise ActiveRecord::Rollback
      end

      all_saved
    end

    def prefill_fields(records, fields)
      fields.each_key.with_object({}) do |field_name, prefilled|
        values = records.map { |record| record.public_send(field_name) }
        values.uniq!
        prefilled[field_name] = values.first if values.size == 1
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
      resource_ids = params[:fields]&.dig(:avo_resource_ids)&.split(",") || []
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

    def decrypted_query
      encrypted_query = params[:fields]&.dig(:avo_selected_query) || params[:query]

      return if encrypted_query.blank?

      Avo::Services::EncryptionService.decrypt(message: encrypted_query, purpose: :select_all, serializer: Marshal)
    end

    def after_bulk_update_path
      resources_path(resource: @resource)
    end
  end
end
