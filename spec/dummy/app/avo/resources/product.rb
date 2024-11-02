require 'net/http'
require 'json'

class Avo::Resources::Product < Avo::BaseResource
  self.title = :title
  self.includes = []
  self.default_view_type = :grid
  self.grid_view = {
    card: -> do
      {
        cover_url: record.image.attached? ? main_app.url_for(record.image.variant(resize: "300x300")) : nil,
        title: record.title,
        body: simple_format(record.description)
      }
    end,
    html: -> do
      {
        cover: {
          index: {
            wrapper: {
              style: "background: pink;"
            }
          }
        }
      }
    end
  }
  self.index_query = -> {
    query.includes image_attachment: :blob
  }

  def fields
    field :id, as: :id
    field :title, as: :text, hide_on: :forms, html: {
      show: {
        label: {
          classes: "bg-gray-50 !text-pink-600"
        },
        content: {
          classes: "bg-gray-50 !text-pink-600"
        },
        wrapper: {
          classes: "bg-gray-50"
        }
      }
    }
    field :combobox_title,
      for_attribute: :title,
      as: :combobox,
      only_on: :forms,
      help: "This is a combobox field and will suggest values based on your query.",
      query: -> {
        # Fetch products from an API
        url = URI("https://dummyjson.com/products/search?q=#{params[:q]}")

        # Make the HTTP request
        response = Net::HTTP.get(url)

        # Parse JSON response
        data = JSON.parse(response)

        data["products"].map { |item| item["title"] }
      }
    field :price, as: :money, currencies: %w[EUR USD RON PEN]
    field :description, as: :tiptap, placeholder: "Enter text", always_show: false
    field :image, as: :file, is_image: true
    field :category, as: :select, enum: ::Product.categories
  end
end
