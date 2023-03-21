class PostResource < Avo::BaseResource
  self.title = :name
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], body_cont: params[:q], m: "or").result(distinct: false)
  end
  self.search_query_help = "- search by id, name or body"
  self.includes = [:user]
  self.default_view_type = :grid
  self.find_record_method = ->(model_class:, id:, params:) {
    !id.is_a?(Array) && id.to_i == 0 ? model_class.find_by_slug(id) : model_class.find(id)
  }

  # self.show_controls = -> do
  #   detach_button
  #   edit_button
  #   link_to "google", "goolee"
  # end

  field :id, as: :id
  field :name, as: :text, required: true, sortable: true
  field :body,
    as: :trix,
    placeholder: "Enter text",
    always_show: false,
    attachment_key: :attachments,
    hide_attachment_url: true,
    hide_attachment_filename: true,
    hide_attachment_filesize: true
  field :tags,
    as: :tags,
    # readonly: true,
    acts_as_taggable_on: :tags,
    close_on_select: false,
    placeholder: "add some tags",
    suggestions: -> { Post.tags_suggestions },
    enforce_suggestions: true,
    help: "The only allowed values here are `one`, `two`, and `three`"
  field :cover_photo, as: :file, is_image: true, as_avatar: :rounded, full_width: true, hide_on: [], accept: "image/*"
  field :cover_photo, as: :external_image, name: "Cover photo", required: true, hide_on: :all, link_to_resource: true, as_avatar: :rounded, format_using: ->(value) { value.present? ? value&.url : nil }
  field :audio, as: :file, is_audio: true, accept: "audio/*"
  field :excerpt, as: :text, hide_on: :all, as_description: true do |model|
    extract_excerpt model.body
  end

  field :is_featured, as: :boolean, visible: ->(resource:) { context[:user].is_admin? }
  field :is_published, as: :boolean do |model|
    model.published_at.present?
  end
  field :user, as: :belongs_to, placeholder: "—"
  field :status, as: :select, enum: ::Post.statuses, display_value: false
  field :slug, as: :text
  field :comments, as: :has_many, use_resource: PhotoCommentResource

  grid do
    cover :cover_photo, as: :file, is_image: true, link_to_resource: true
    title :name, as: :text, required: true, link_to_resource: true
    body :excerpt, as: :text do |model|
      extract_excerpt model.body
    end
  end

  filter FeaturedFilter
  filter PublishedFilter
  filter PostStatusFilter

  action TogglePublished
end
