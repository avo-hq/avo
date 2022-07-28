class TestResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.model_class = ::Comment
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :tiny_name, as: :text, only_on: :index, as_description: true
end
