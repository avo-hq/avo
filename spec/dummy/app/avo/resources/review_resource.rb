class ReviewResource < Avo::BaseResource
  self.title = :tiny_name
  self.includes = [:user, :reviewable]
  self.description = "Demo resource to illustrate searchable belongs_to associations. Visit a team and create a review for it."
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :body, as: :textarea
  field :excerpt, as: :text, only_on: :index, as_description: true do |model|
    ActionView::Base.full_sanitizer.sanitize(model.body.to_s).truncate 60
  rescue
    ""
  end

  field :user,
    as: :belongs_to,
    searchable: true,
    allow_via_detaching: true,
    help: "For the review with the ID of 1 only admin users will be displayed.",
    attach_scope: -> do
      # For the parent record with ID 1 we'll apply this rule.
      # This is for testing purposes only. Just to show that it's possbile.
      if parent.present? && parent.id == 1
        query.admins
      else
        query
      end
    end
  field :reviewable,
    as: :belongs_to,
    polymorphic_as: :reviewable,
    types: [::Fish, ::Post, ::Project, ::Team],
    searchable: true,
    allow_via_detaching: true,
    html: {
      data: {
        "resource-edit-target": "emailField",
        action: "input->resource-edit#emailUpdate"
      }
    },
    attach_scope: -> do
      # For the parent record with ID 1 we'll apply this rule.
      # This is for testing purposes only. Just to show that it's possbile.
      if parent.present? && parent.id == 1
        query.where("lower(name) like ?", "%#{parent.body[0].downcase}%")
      else
        query
      end
    end,
    polymorphic_help: "Select the polymorphic type",
    help: "For the review with the ID of 1 the scope is modified. Please check the code under <code>review_resource.rb</code>"
end
