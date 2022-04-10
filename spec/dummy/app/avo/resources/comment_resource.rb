class CommentResource < Avo::BaseResource
  self.title = :tiny_name
  self.includes = [:user, :commentable]
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  self.record_selector = false

  self.after_create_path = :index
  self.after_update_path = :index

  field :id, as: :id
  field :body, as: :textarea
  field :tiny_name, as: :text, only_on: :index, as_description: true

  field :user, as: :belongs_to
  field :commentable, as: :belongs_to, polymorphic_as: :commentable, types: [::Post, ::Project]
end
