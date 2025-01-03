class Avo::Resources::Product < Avo::BaseResource
  self.title = :title
  self.includes = []
  self.default_view_type = :grid
  self.grid_view = {
    card: -> do
      {
        cover_url: record.image.attached? ? main_app.url_for(record.image.variant(resize: "300x300")) : nil,
        title: record.title,
        body: simple_format(record.description),
        badge_label: (record.updated_at < 1.week.ago) ? "New" : "Updated",
        badge_color: (record.updated_at < 1.week.ago) ? "green" : "orange",
        badge_title: (record.updated_at < 1.week.ago) ? "New product here" : "Updated product here"
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
    field :title, as: :text, html: {
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
    field :price, as: :money, currencies: %w[EUR USD RON PEN]
    field :description, as: :tiptap, placeholder: "Enter text", always_show: false
    field :image, as: :file, is_image: true
    field :category, as: :select, enum: ::Product.categories
    field :sizes, as: :select, multiple: true, options: {"Large": :large, "Medium": :medium, "Small": :small}
  end
end
