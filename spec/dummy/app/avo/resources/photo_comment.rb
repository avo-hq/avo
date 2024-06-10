# frozen_string_literal: true

class Avo::Resources::PhotoComment < Avo::BaseResource
  self.title = :tiny_name
  self.includes = [:user, [photo_attachment: :blob]]
  self.model_class = ::Comment
  self.search = {
    query: -> {
      if params[:via_association] == "has_many"
        query.ransack(id_eq: params[:q], m: "or").result(distinct: false).joins(:photo_attachment)
      else
        query.ransack(id_eq: params[:q], m: "or").result(distinct: false)
      end
    }
  }

  def fields
    field :id, as: :id
    field :body, as: :textarea
    field :tiny_name, as: :text, only_on: :index
    field :photo, as: :file, is_image: true, as_avatar: :rounded, full_width: true, hide_on: [], accept: "image/*"
    field :user, as: :belongs_to
    field :commentable_type, as: :hidden, default: "Post"
    field :commentable_id, as: :hidden, default: -> { Avo::Current.params[:via_record_id] }
  end

  def actions
    action Avo::Actions::DeleteComment
  end

  def filters
    filter Avo::Filters::PhotoFilter
  end
end
