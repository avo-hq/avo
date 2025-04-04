class Avo::Resources::Product < Avo::BaseResource
  self.title = :title
  self.includes = []
  self.default_view_type = :grid
  self.grid_view = {
    card: -> do
      {
        cover_url: record.image.attached? ? main_app.url_for(record.image.variant(resize_to_fill: [300, 300])) : nil,
        title: record.title,
        body: simple_format(record.description) + " \n #{record.updated_at.to_datetime.strftime("%d %b %Y %H:%M:%S")}",
        badge_label: (record.status == :new) ? "New" : "Updated",
        badge_color: (record.status == :new) ? "green" : "orange",
        badge_title: (record.status == :new) ? "New product here" : "Updated product here"
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
  self.discreet_information = [
    {
      tooltip: -> { sanitize("Product is <strong>#{record.status}</strong>", tags: %w[strong]) },
      icon: -> { "heroicons/outline/#{(record.status == :new) ? "arrow-trending-up" : "arrow-trending-down"}" }
    },
    :timestamps
  ]
  self.profile_photo = {
    source: -> { record.image.attached? ? main_app.url_for(record.image.variant(resize_to_fill: [300, 300])) : nil }
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
    field :sizes, as: :select, multiple: true, options: {Large: :large, Medium: :medium, Small: :small}

    field :updated_at, as: :date_time
  end

  def actions
    action Avo::Actions::UpdateProduct, arguments: {view_type: params[:view_type]}
  end
end
