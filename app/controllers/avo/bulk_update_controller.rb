module Avo
  class BulkUpdateController < ResourcesController
    before_action :set_query, only: [:edit, :handle]

    def edit
      @resource.hydrate(record: @resource.model_class.new(bulk_values))

      set_component_for :bulk_edit, fallback_view: :edit
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

    # This method returns a hash of the attributes of the model and their values
    # If all the records have the same value for an attribute, the value is assigned to the attribute, otherwise nil is assigned
    def bulk_values
      @resource.model_class.attribute_names.map do |attribute_key|
        values = @query.map { _1.public_send(attribute_key) }.uniq

        [attribute_key, values.size == 1 ? values.first : nil]
      end.to_h
    end

    def set_query
      resource_ids = params[:fields]&.dig(:avo_resource_ids)&.split(",") || []
      @query = decrypted_query || (resource_ids.any? ? @resource.find_record(resource_ids, params: params) : [])
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
