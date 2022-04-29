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

  field :user, as: :belongs_to, scope: -> do
    # For the parent record with ID 1 we'll apply this rule.
    # This is for testing purposes only. Just to show that it's possbile.
    if parent.present? && parent.id == 1 && params[:like].present?
      query.where("lower(first_name) like ?", "%#{params[:like]}%")
    else
      query
    end
  end
  field :commentable, as: :belongs_to, polymorphic_as: :commentable, types: [::Post, ::Project], scope: -> do
    # For the parent record with ID 1 we'll apply this rule.
    # This is for testing purposes only. Just to show that it's possbile.
    if parent.present? && parent.id == 1 && params[:like].present?
      query.where("lower(name) like ?", "%#{params[:like]}%")
    else
      query
    end
  end
end
