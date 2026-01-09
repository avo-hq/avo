class Avo::Resources::Post < Avo::BaseResource
  self.title = :name
  self.search = {
    query: -> {
      query.ransack(id_eq: params[:q], name_cont: params[:q], body_cont: params[:q], m: "or").result(distinct: false)
    },
    help: "- search by id, name or body"
  }

  self.includes = [:user, :comments]
  self.attachments = [:cover, :audio, :attachments]
  self.single_includes = [:user, :reviews]
  self.single_attachments = [:cover, :audio, :attachments]
  self.default_view_type = -> {
    mobile_user = request.user_agent =~ /Mobile/

    mobile_user ? :table : :grid
  }
  self.find_record_method = -> {
    if id.is_a?(Array)
      query.where(slug: id)
    else
      query.find_by_slug(id)
    end
  }
  self.view_types = [:grid, :table]
  # Show a link to the post outside Avo
  self.external_link = -> {
    main_app.post_path(record)
  }

  self.discreet_information = [
    :timestamps,
    {
      tooltip: -> { sanitize("Product is <strong>#{record.published_at ? "published" : "draft"}</strong>", tags: %w[strong]) },
      icon: -> { "heroicons/outline/#{record.published_at ? "eye" : "eye-slash"}" }
    },
    {
      label: -> { record.published_at ? "✅" : "🙄" },
      tooltip: -> { "Post is #{record.published_at ? "published" : "draft"}. Click to toggle." },
      url: -> {
        Avo::Actions::TogglePublished.path(
          resource: resource,
          arguments: {
            records: Array.wrap(record.id),
            confirmation: false,
            in_discreet_information: true
          }
        )
      },
      data: Avo::BaseAction::DATA_ATTRIBUTES
    }
  ]

  def fields
    field :id, as: :id
    field :name, required: true, sortable: true
    field :created_at, as: :date_time
    field :body,
      as: :trix,
      placeholder: "Enter text",
      always_show: false,
      attachment_key: :attachments,
      hide_attachment_url: true,
      hide_attachment_filename: true,
      hide_attachment_filesize: true
    field :cover, as: :file, is_image: true, full_width: true, hide_on: [], accept: "image/*", stacked: true
    field :cover, as: :external_image, name: "Cover photo", required: true, hide_on: :all, link_to_record: true, format_using: -> { value.present? ? value&.url : nil }
    field :audio, as: :file, is_audio: true, accept: "audio/*"

    field :is_featured, as: :boolean, visible: -> do
      Avo::Current.context[:user].is_admin?
    end
    field :is_published, as: :boolean do
      record.published_at.present?
    end
    field :user, as: :belongs_to, placeholder: "—"
    field :status, as: :select, enum: ::Post.statuses, display_value: false
    field :slug, as: :text
    field :tags, as: :tags,
      acts_as_taggable_on: :tags,
      close_on_select: false,
      placeholder: "add some tags",
      suggestions: -> { Post.tags_suggestions },
      enforce_suggestions: true,
      # suggestions_max_items: 2,
      help: "The only allowed values here are `one`, `two`, and `three`"

    field :cover_attachment, as: :has_one

    field :comments, as: :has_many, use_resource: Avo::Resources::PhotoComment
  end

  self.grid_view = {
    card: -> do
      {
        cover_url:
          if record.cover.attached?
            main_app.url_for(record.cover)
          end,
        title: record.name,
        body: helpers.extract_excerpt(record.body) + "(Published: #{record.published_at.present? ? "✅" : "❌"})"
      }
    end
    # html: -> do
    #   {
    #     title: {
    #       index: {
    #         wrapper: {
    #           classes: "bg-blue-50 rounded-md p-2"
    #         }
    #       }
    #     },
    #     body: {
    #       index: {
    #         wrapper: {
    #           classes: "bg-gray-50 rounded-md p-1"
    #         }
    #       }
    #     }
    #   }
    # end
  }

  def filters
    filter Avo::Filters::FeaturedFilter
    filter Avo::Filters::PublishedFilter
    filter Avo::Filters::PostStatusFilter
  end

  def actions
    action Avo::Actions::TogglePublished
  end
end
