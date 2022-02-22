class ReviewResource < Avo::BaseResource
  self.title = :tiny_name
  self.includes = []
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

  field :user, as: :belongs_to, searchable: true
  field :reviewable, as: :belongs_to, polymorphic_as: :reviewable, types: [::Fish, ::Post, ::Project, ::Team], searchable: true
end
