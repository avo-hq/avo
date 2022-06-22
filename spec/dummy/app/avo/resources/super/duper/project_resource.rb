class Super::Duper::ProjectResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.model_class = ::Project
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :name, as: :text
  field :users, as: :has_and_belongs_to_many
  field :comments, as: :has_many
  field :reviews, as: :has_many
  # add fields here
end
