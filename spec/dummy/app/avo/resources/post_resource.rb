class PostResource < Avo::BaseResource
  self.title = :name
  self.search = [:name, :id]
  self.includes = :user
  self.default_view_type = :grid

  fields do |f|
    f.id
    f.text :name, required: true
    f.trix :body, placeholder: 'Enter text', always_show: false
    f.file :cover_photo, is_image: true, link_to_resource: true
    f.boolean :is_featured, can_see: -> () { context[:user].is_admin? }
    f.boolean :is_published do |model|
      model.published_at.present?
    end

    f.belongs_to :user, meta: { searchable: false }, placeholder: '—'
  end

  grid do |cover, title, body|
    cover.file :cover_photo, required: true, link_to_resource: true
    title.text :name, required: true, link_to_resource: true
    body.text :excerpt do |model|
      begin
        ActionView::Base.full_sanitizer.sanitize(model.body).truncate 130
      rescue => exception
        ''
      end
    end
  end

  filters do |f|
    f.use FeaturedFilter
    f.use PublishedFilter
  end

  actions do |a|
    a.use TogglePublished
  end
end
