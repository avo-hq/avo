class ProductResource < Avo::BaseResource
  self.title = :title
  self.includes = []
  self.default_view_type = :grid

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
        classes: "bg-gray-50 !text-pink-600"
      }
    }
  }
  field :description, as: :trix
  field :image, as: :file, is_image: true
  field :price, as: :number
  field :category, as: :select, enum: ::Product.categories
  field :vat_tax, as: :select, options: {
    'Zero': 0,
    'Low': 13,
    'Standard': 16,
    'High': 23,
  }

  grid do
    cover :image, as: :file, is_image: true, link_to_resource: true, html: {
      index: {
        wrapper: {
          style: "background: pink;"
        }
      }
    }
    title :title, as: :text
    body :description, as: :textarea, format_using: ->(value) {
      simple_format value
    }
  end
end
