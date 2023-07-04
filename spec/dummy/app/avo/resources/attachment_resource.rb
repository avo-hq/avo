class AttachmentResource < Avo::BaseResource
  self.title = :filename
  self.model_class = "ActiveStorage::Attachment"

  field :id, as: :id
  field :filename, as: :text
  field :service_url, as: :external_image, name: "Image"
  field :created_at, as: :date_time
end
