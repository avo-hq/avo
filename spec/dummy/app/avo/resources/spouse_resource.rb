class SpouseResource < Avo::BaseResource
  self.title = :name
  self.description = "Demo resource to illustrate Avo\'s Single Table Inheritance support (Spouse < Person)"
  self.includes = []
  self.model_class = ::Spouse
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  field :name, as: :text
end
