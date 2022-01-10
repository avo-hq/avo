class PersonResource < Avo::BaseResource
  self.title = :name
  self.includes = []

  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :name, as: :text, link_to_resource: true
  field :type, as: :select, name: "Type", options: { Spouse: "Spouse" }
end
