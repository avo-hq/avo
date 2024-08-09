# frozen_string_literal: true

class Avo::Fields::Common::Files::ControlsComponent < Avo::BaseComponent
  include Avo::ApplicationHelper
  include Avo::Fields::Concerns::FileAuthorization

  delegate :id, to: :field

  prop :field, Avo::Fields::BaseField, reader: :public
  prop :file, ActiveStorage::Attached, reader: :public
  prop :resource, Avo::BaseResource, reader: :public

  def destroy_path
    Avo::Services::URIService.parse(@resource.record_path).append_paths("active_storage_attachments", id, file.id).to_s
  end
end
