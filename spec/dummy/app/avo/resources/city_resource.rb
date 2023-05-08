# frozen_string_literal: true

class CityResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(name_eq: params[:q]).result(distinct: false)
  end
  self.search_result_path = -> do
    avo.resources_city_path record, custom: "yup"
  end
  self.extra_params = [:fish_type, :something_else, properties: [], information: [:name, :history]]
  self.default_view_type = :map
  self.map_view = {
    mapkick_options: {
      controls: true
    },
    record_marker: -> {
      {
        latitude: record.coordinates.first,
        longitude: record.coordinates.last,
        tooltip: record.name
      }
    },
    table: {
      visible: true,
      layout: :bottom
    }
  }

  field :id, as: :id
  field :coordinates, as: :location, stored_as: [:latitude, :longitude]
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
