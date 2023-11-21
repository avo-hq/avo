class Avo::Resources::Post < Avo::BaseResource
  self.title = :name
  self.search = {
    query: -> {
      query.ransack(id_eq: params[:q], name_cont: params[:q], body_cont: params[:q], m: "or").result(distinct: false)
    },
    help: "- search by id, name or body"
  }

  self.includes = [:user]
  self.default_view_type = :grid
  self.find_record_method = -> {
    # When using friendly_id, we need to check if the id is a slug or an id.
    # If it's a slug, we need to use the find_by_slug method.
    # If it's an id, we need to use the find method.
    # If the id is an array, we need to use the where method in order to return a collection.
    if id.is_a?(Array)
      id.first.to_i == 0 ? query.where(slug: id) : query.where(id: id)
    else
      id.to_i == 0 ? query.find_by_slug(id) : query.find(id)
    end
  }
  self.view_types = [:grid, :table]

  def fields
    field :id, as: :id
    field :name, required: true, sortable: true
    field :body,
      as: :trix,
      placeholder: "Enter text",
      always_show: false,
      attachment_key: :attachments,
      hide_attachment_url: true,
      hide_attachment_filename: true,
      hide_attachment_filesize: true
    field :cover_photo, as: :file, is_image: true, as_avatar: :rounded, full_width: true, hide_on: [], accept: "image/*"
    field :cover_photo, as: :external_image, name: "Cover photo", required: true, hide_on: :all, link_to_record: true, as_avatar: :rounded, format_using: -> { value.present? ? value&.url : nil }
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

    field :cover_photo_attachment, as: :has_one

    field :comments, as: :has_many, use_resource: Avo::Resources::PhotoComment
  end

  self.grid_view = {
    card: -> do
      {
        cover_url:
          if record.cover_photo.attached?
            main_app.url_for(record.cover_photo.url)
          end,
        title: record.name,
        body: helpers.extract_excerpt(record.body)
      }
    end,
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
