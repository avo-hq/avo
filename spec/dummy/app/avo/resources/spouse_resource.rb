class SpouseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.model_class = ::Spouse
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  field :name, as: :text
end
