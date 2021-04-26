class PostResource < Avo::BaseResource
  self.title = :name
  self.search = [:name, :id]
  self.includes = :user
  self.default_view_type = :grid

  field :id, as: :id
  field :name, as: :text, required: true
  field :body, as: :trix, placeholder: "Enter text", always_show: false
  field :cover_photo, as: :file, is_image: true, link_to_resource: true
  field :is_featured, as: :boolean, visible: ->(resource:) { context[:user].is_admin? }
  field :is_published, as: :boolean do |model|
    model.published_at.present?
  end
  field :user, as: :belongs_to, meta: {searchable: false}, placeholder: "—"
  field :status, as: :select, enum: ::Post.statuses, display_value: false

  grid do
    cover :cover_photo, as: :file, link_to_resource: true
    title :name, as: :text, required: true, link_to_resource: true
    body :excerpt, as: :text do |model|
      ActionView::Base.full_sanitizer.sanitize(model.body).truncate 130
    rescue
      ""
    end
  end

  filter FeaturedFilter
  filter PublishedFilter
  filter PostStatusFilter

  action TogglePublished
end
