class Avo::Resources::ActiveRecordAttachment < Avo::Resources::ActiveRecord
  self.title = :filename
  self.model_class = "ActiveStorage::Attachment"
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id
    field :filename, as: :text
    field :service_url, as: :external_image, name: "Image"
    field :created_at, as: :date_time
  end
end
