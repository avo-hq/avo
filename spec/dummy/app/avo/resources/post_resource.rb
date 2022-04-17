class PostResource < Avo::BaseResource
  self.title = :name
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], body_cont: params[:q], m: "or").result(distinct: false)
  end
  self.search_query_help = "- search by id, name or body"
  self.includes = :user
  self.default_view_type = :grid

  field :id, as: :id
  field :tags,
    as: :tags,
    # disabled: true,
    acts_as_taggable_on: :tags,
    close_on_select: false,
    placeholder: 'add some tags',
    suggestions: -> {
      [
        {
          value: 1,
          label: 'one',
          # avatar: 'https://www.gravatar.com/avatar/486187eddec3e74a7b9f38a69fc60e07?default=&size=100',
        },
        {
          value: 2,
          label: 'two',
          avatar: 'https://www.gravatar.com/avatar/486187eddec3e74a7b9f38a69fc60e07?default=&size=100',
        },
        {
          value: 3,
          label: 'three',
          avatar: 'https://www.gravatar.com/avatar/486187eddec3e74a7b9f38a69fc60e07?default=&size=100',
        },
      ]
    },
    enforce_suggestions: true

  field :name, as: :text, required: true, sortable: true
  # field :body, as: :trix, placeholder: "Enter text", always_show: false, attachment_key: :attachments, hide_attachment_url: true, hide_attachment_filename: true, hide_attachment_filesize: true
  # field :cover_photo, as: :file, is_image: true, as_avatar: :rounded, full_width: true, hide_on: []
  # field :cover_photo, as: :external_image, name: 'Cover photo', required: true, hide_on: :all, link_to_resource: true, as_avatar: :rounded, format_using: ->(value) { value.present? ? value&.url : nil }
  # field :audio, as: :file, is_audio: true
  # field :excerpt, as: :text, hide_on: :all, as_description: true do |model|
  #   ActionView::Base.full_sanitizer.sanitize(model.body).truncate 130
  # rescue
  #   ""
  # end

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
