# frozen_string_literal: true

class Avo::Fields::EncryptedTextField::ShowComponent < Avo::Fields::ShowComponent
  def reveal_path
    helpers.avo.avo_api_reveal_encrypted_field_path(
      resource_name: @resource.route_key,
      id: @resource.record.to_param,
      field_id: @field.id
    )
  end
end
