module Avo
  module Resources
    class Post < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :user
        @default_view_type = :grid
      end

      fields do
        id
        text :name, required: true
        trix :body, placeholder: 'Enter text', always_show: false
        file :cover_photo, is_image: true
        boolean :is_featured
        boolean :is_published do |model|
          model.published_at.present?
        end


        belongs_to :user, searchable: false, placeholder: '—'
      end

      # These fields are a reference on the already configured fields above
      grid do
        preview :cover_photo
        title :name
        body :body
      end

      use_filter Avo::Filters::FeaturedFilter
      use_filter Avo::Filters::PublishedFilter

      use_action Avo::Actions::TogglePublished
    end
  end
end
