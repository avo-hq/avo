class Avo::Resources::Book < Avo::Resources::Http
  self.endpoint = "https://stephen-king-api.onrender.com/api/books"

  def fields
    field :id, as: :id
    field :filename, as: :text
    field :service_url, as: :external_image, name: "Image"
    field :created_at, as: :date_time
  end
end
