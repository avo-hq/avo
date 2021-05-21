class CommentResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :body, as: :textarea
  field :excerpt, as: :text, show_on: :index, as_description: true do |model|
    ActionView::Base.full_sanitizer.sanitize(model.body).truncate 60
  rescue
    ""
  end

  field :user, as: :belongs_to
  field :post, as: :belongs_to, polymorphic_as: :commentable, polymorphic_for: ::Post
  field :project, as: :belongs_to, polymorphic_as: :commentable, polymorphic_for: ::Project
end
