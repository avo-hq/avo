class CityResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  self.extra_params = [:fish_type, :something_else, properties: [], information: [:name, :history]]

  field :id, as: :id
  with_options hide_on: :forms do
    field :name, as: :text, help: "The name of your city"
    field :population, as: :number
    field :is_capital, as: :boolean
    field :features, as: :key_value
    field :metadata, as: :code
    field :image_url, as: :external_image
    field :description, as: :trix
    field :tiny_description, as: :markdown
    field :status, as: :badge, enum: ::City.statuses
  end

  tool CityEditor, only_on: :forms
end
