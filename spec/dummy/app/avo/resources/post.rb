module Avo
  module Resources
    class Post < Resource
      def configure
        @title = :name
        @search = [:name, :id]
        @includes = :user
        # @default_view_type = :grid
      end

      def fields(request)
        f.id
        f.text :name, required: true
        f.textarea :body, rows: 10
        # f.trix :body, placeholder: 'Enter text', always_show: false
        # f.text :excerpt, hide_on: [:show, :edit, :index] do |model|
        #   begin
        #     ActionView::Base.full_sanitizer.sanitize(model.body).truncate 130
        #   rescue => exception
        #     ''
        #   end
        # end
        # f.file :cover_photo, is_image: true
        f.boolean :is_featured, can_see: -> () { user.is_admin? }
        f.boolean :is_published do |model|
          model.published_at.present?
        end

        f.belongs_to :user, meta: { searchable: false }, placeholder: '—'

        # Grid view
        # f.text :name, required: true, show_on_grid: :preview
        f.text :name, required: true, show_on_grid: :title
        f.text :name, required: true, show_on_grid: :body
      end

      # # use_filter Avo::Filters::FeaturedFilter
      # # use_filter Avo::Filters::PublishedFilter

      use_action Avo::Actions::TogglePublished
    end
  end
end
