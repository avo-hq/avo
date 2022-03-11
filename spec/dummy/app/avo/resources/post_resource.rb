class PostResource < Avo::BaseResource
  self.title = :name
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], body_cont: params[:q], m: "or").result(distinct: false)
  end
  self.search_query_help = "- search by id, name or body"
  self.includes = :user
  self.default_view_type = :grid

  field :id, as: :id
  field :name, as: :text, required: true
  field :body, as: :trix, placeholder: "Enter text", always_show: false, attachment_key: :attachments, hide_attachment_url: true, hide_attachment_filename: true, hide_attachment_filesize: true
  field :cover_photo, as: :file, is_image: true, as_avatar: :rounded, full_width: true, hide_on: [:index]
  field :cover_photo, as: :external_image, name: 'Cover photo', required: true, only_on: [:index], link_to_resource: true, as_avatar: :rounded, format_using: ->(value) { value.present? ? value&.url : nil }
  field :audio, as: :file, is_audio: true
  field :excerpt, as: :text, hide_on: :all, as_description: true do |model|
    ActionView::Base.full_sanitizer.sanitize(model.body).truncate 130
  rescue
    ""
  end

  field :is_featured, as: :boolean, visible: ->(resource:) { context[:user].is_admin? }
  field :is_published, as: :boolean do |model|
    model.published_at.present?
  end
  field :user, as: :belongs_to, placeholder: "—"
  field :status, as: :select, enum: ::Post.statuses, display_value: false
  field :comments, as: :has_many

  grid do
    cover :cover_photo, as: :file, is_image: true, link_to_resource: true
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
