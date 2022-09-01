class TeamUserResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.model_class = 'User'
  self.resolve_find_scope = ->(model_class:) do
    model_class.friendly
  end
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # add fields here
end
