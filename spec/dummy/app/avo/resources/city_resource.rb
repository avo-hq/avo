class CityResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = lambda {
    scope.ransack(name_eq: params[:q]).result(distinct: false)
  }
  self.search_result_path = lambda {
    avo.resources_city_path record, custom: 'yup'
  }
  self.extra_params = [:fish_type, :something_else, { properties: [], information: %i[name history] }]

  field :id, as: :id
  field :coordinates, as: :location, stored_as: %i[latitude longitude]
  with_options hide_on: :forms do
    field :name, as: :text, help: 'The name of your city'
    field :population, as: :number
    field :is_capital, as: :boolean
    field :features, as: :key_value
    field :metadata, as: :code
    field :image_url, as: :external_image
    field :description, as: :trix
    field :tiny_description, as: :markdown
    field :city_center_area, as: :area, geometry: :multi_polygon,
                             style: 'mapbox://styles/mapbox/satellite-v9',
                             options: { label: 'Paris City Center',
                                        tooltip: 'Bonjour mes amis!',
                                        color: '#009099' }
    field :status, as: :badge, enum: ::City.statuses
  end

  tool CityEditor, only_on: :forms
end
