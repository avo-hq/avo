class PostResource < BaseResource
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

  def grid
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

  def filters
    filter.use FeaturedFilter
    filter.use PublishedFilter
  end

  def actions
    a.use TogglePublished
  end
end
