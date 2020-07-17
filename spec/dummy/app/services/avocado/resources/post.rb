module Avocado
  module Resources
    class Post < Resource
      def initialize
        @title = :name
        @search = [:name, :id]
        @includes = :user
      end

      fields do
        id
        text :name, required: true
        textarea :body, nullable: true, null_values: ['0', '', 'null', 'nil']
        file :cover_photo, is_image: true
        boolean :is_featured
        boolean :is_published do |model|
          model.published_at.present?
        end

        belongs_to :user, searchable: false, placeholder: '—'
      end

      use_filter Avocado::Filters::FeaturedFilter
      use_filter Avocado::Filters::PublishedFilter
    end
  end
end
