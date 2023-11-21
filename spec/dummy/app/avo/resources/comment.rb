class Avo::Resources::Comment < Avo::BaseResource
  self.title = :tiny_name
  self.includes = [:user, :commentable]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], body_cont: params[:q], m: "or").result(distinct: false) }
  }

  self.record_selector = false

  self.after_create_path = :index
  self.after_update_path = :index

  def fields
    field :id, as: :id
    field :body, as: :textarea, format_using: -> do
      if view.show?
        content_tag(:div, style: "white-space: pre-line") { value }
      else
        value
      end
    end
    field :tiny_name, as: :text, only_on: :index
    field :posted_at,
      as: :date_time,
      picker_format: "Y-m-d H:i:S",
      format: "cccc, d LLLL yyyy, HH:mm ZZZZ" # Wednesday, 10 February 1988, 16:00 GMT
      field :user, as: :belongs_to, use_resource: Avo::Resources::CompactUser
      field :commentable, as: :belongs_to, polymorphic_as: :commentable, types: [::Post, ::Project]
  end

  def filters
    filter Avo::Filters::CommentBodyFilter
  end
end
