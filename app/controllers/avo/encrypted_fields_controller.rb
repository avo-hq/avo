# frozen_string_literal: true

require_dependency "avo/application_controller"

module Avo
  class EncryptedFieldsController < ApplicationController
    before_action :set_resource_name
    before_action :set_resource
    before_action :set_record
    # BaseController runs this for resource pages; we must load field definitions
    # or get_field_definitions is empty and find_field never matches.
    before_action :detect_fields, only: :reveal
    before_action :authorize_reveal

    def reveal
      field = find_field

      unless field
        render json: { error: "Field not found" }, status: :not_found
        return
      end

      value = @record.public_send(field.id)

      render json: { value: value }
    end

    private

    def find_field
      @resource.get_field_definitions.find do |f|
        f.id.to_s == params[:field_id].to_s && f.is_a?(Avo::Fields::EncryptedTextField)
      end
    end

    def authorize_reveal
      authorize_action(:show)
    rescue Avo::NotAuthorizedError
      render json: { error: "Not authorized" }, status: :forbidden
    end
  end
end
