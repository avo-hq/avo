module Avo
  module Resources
    class Post < Resource
      def configure
        @title = :name
        @search = [:name, :id]
        @includes = :user
        @default_view_type = :grid
      end

      def fields(request)
        f.id
        f.text :name, required: true
        f.trix :body, placeholder: 'Enter text', always_show: false
        f.file :cover_photo, is_image: true, link_to_resource: true
        f.boolean :is_featured, can_see: -> () { user.is_admin? }
        f.boolean :is_published do |model|
          model.published_at.present?
        end

        f.belongs_to :user, meta: { searchable: false }, placeholder: '—'
      end

      def grid(request)
        g.file :cover_photo, required: true, grid_position: :preview, link_to_resource: true
        g.text :name, required: true, grid_position: :title, link_to_resource: true
        g.text :excerpt, grid_position: :body do |model|
          begin
            ActionView::Base.full_sanitizer.sanitize(model.body).truncate 130
          rescue => exception
            ''
          end
        end
      end

      def filters(request)
        filter.use Avo::Filters::FeaturedFilter
        filter.use Avo::Filters::PublishedFilter
      end

      def actions(request)
        a.use Avo::Actions::TogglePublished
      end
    end
  end
end
