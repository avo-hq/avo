# frozen_string_literal: true

class PhotoCommentResource < Avo::BaseResource
  self.title = :tiny_name
  self.includes = [:user]
  self.model_class = ::Comment
  self.authorization_policy = PhotoCommentPolicy
  self.search_query = -> do
    if params[:via_association] == "has_many"
      scope.ransack(id_eq: params[:q], m: "or").result(distinct: false).joins(:photo_attachment)
    else
      scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
    end
  end

  field :id, as: :id
  field :body, as: :textarea, format_using: ->(value) do
    if view == :show
      content_tag(:div, style: "white-space: pre-line") { value }
    else
      value
    end
  end
  field :tiny_name, as: :text, only_on: :index, as_description: true
  field :photo, as: :file, is_image: true, as_avatar: :rounded, full_width: true, hide_on: [], accept: "image/*"
  field :user, as: :belongs_to

  field :commentable_type, as: :hidden, default: "Post"
  field :commentable_id, as: :hidden, default: -> { Avo::App.params[:via_resource_id] }

  action DeleteComment

  filter PhotoFilter
end
